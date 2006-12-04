From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Dec 2006 12:35:55 +0000
Subject: Re: [PATCH] [RFC]: Fine-grained sending rate resolution / division errors
Message-Id: <200612041235.56077@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611292052.01303@strip-the-willow>
In-Reply-To: <200611292052.01303@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
o:
|  > |  > Here is now the patch, I have had a hard time due to division of u64 by
|  > |  > u32. I have also checked again - it is feasible to prune X_calc and
|  > |  > X_recv back to u32. If you prefer that, I can change the patch.
|  > |
|  > |  If it is possible, its better, minus 8 bytes per half connection
|  > I have checked again - the best that seems possible is 4 bytes less. This
|  > is due to X_recv which acts as cache in [RFC 3448, 4.4] - lots of division
|  > operations where the value needs to be stored afterwards again.
|  > So X_calc would remain as 32bit, I will write up how I think it should look
|  > like and revise the patch - tomorrow, since the bug hunting took some time
|  > away.
|  
|  OK, take your time.

Please find attached, below, the revised plan for finer-grained resolution; I am using
' << 6' for all scaling operations, for consistency. Patch to codify this follows later.


	Revised approach to achieve finer-grained resolution of sending rates
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	I) Summary
	----------
	The sending rate X and the cached value X_recv of the receiver-estimated
	sending rate are both scaled by 64 (2^6) in order to: 
		* cope with low sending	rates (minimally 1 byte/second)
		* allow upgrading to a packets-per-second sending principle
		* avoid calculation errors due to integer arithmetic
	The following data types are used:
		* u32 X_calc  -  is maintained in      bytes/second
		* u64 X		  -  is maintained in 64 * bytes/second	
		* u64 X_recv  -  is maintained in 64 * bytes/second	
	This choice is a compromise between minimising the size of sender
	data structures and requirements. X needs to be u64 to avoid overflow,
	X_recv needs a finer granularity to avoid underflow when modifying the
	cached value via the nofeedback timer [RFC 3448, 4.4].
	
	Furthermore, the usecs_div() function should be replaced by:
		* u64 scaled_div(u64 a, u32 b)   -- where u64 is safe 
		* u32 scaled_div32(u64 a, u32 b) -- which tests against overflow


	II) Initialisation [RFC 3448, 4.2]
	----------------------------------
	Set X[/s] to 64 * 1 packet / second 	(i.e.,  X  =  s << 6)
	
	
	III) Sender behaviour when a feedback packet is received
	--------------------------------------------------------
	(a) Scale X_recv when it is received:
	 
	     X_recv  =  hctx->packet_options_x_recv << 6
	
	(b) Step (4) of  [RFC 3448, 4.3]:
		
		If (p > 0) {

          		X_calc = calcX(s, R, p)	
            
          	        X  =  min(X_calc << 6, 2 * X_recv)   	/* X_recv is already scaled */
  			X  =  max(X, (s << 6)/t_mbi)

  		} Else If(t_now - tld >= R) {
  		
  			X  =  2 * min(X, X_recv)
  			X  =  max(X, scaled_div(s << 6, R))	/*  R in microseconds */
		
			tld = t_now
  		}
  		
  	(c) Step (5) of  [RFC 3448, 4.3]: 
  		The nofeedback timer is set to expire in 
  		t_nfb =	max(4 * R, scaled_div32(2 * s, X >> 6)) 
  			
  			
	IV) Expiration of the nofeedback timer [RFC 3448, 4.4]
	------------------------------------------------------
	(a) If the sender has previously received feedback from the receiver
		
		If (p = 0 ||  
		    X_calc > (X_recv >> 5))   		/* divided by 2^6, multiplied by 2^1 */
		
			X_recv  =  max(X_recv/2, (s << 6)/(2*t_mbi))

		Else
				
			X_recv  =  X_calc << 4		/* scaled by 2^6, divided by 2^2 */
			
	
		/* recalculate X according to [RFC 3448, 4.3]   */
		
		/* expire the nofeedback timer after: */
		t_nfb = max(4 * R, scaled_div32(2 * s, X >> 6))
					  
					  
	(b) If the sender does not yet have feedback
	
		X  =  max(X/2, (s << 6)/t_mbi)
		
		/* set the nofeedback timer to expire after 2 seconds */

					  

	V) Scheduling of Packet Transmissions [RFC 3448, 4.6]
	-----------------------------------------------------
	        
	        t_ipi   =   scaled_div(s, X >> 6)           /* microseconds */
      
	VI) Larger initial windows [RFC 4342, sec. 5]
	---------------------------------------------
            w_init  =  min(4*s , max(2*s, 4380))
            X       =  scaled_div(w_init << 6, R)
            

	VII) Overflow analysis of scaled_div/scaled_div32
	-------------------------------------------------
	The way the functions are used as above is safe, since:
	
	IIIb):  X  =  max(X, scaled_div(s << 6, R))
	        Is safe since (2^32 - 1)*64*1E6 fit in u64
	        
	IIIc):  t_nfb = max(4 * R, scaled_div32(2 * s, X >> 6))
			This can overflow (e.g. s=(2^32 -1) and X>>6 = 1),
			hence we need the overflow test of scaled_div32
			
	IVa):   analogous to IIIc
	
	V):     t_ipi = scaled_div(s, X >> 6)
			This is safe on u32, since s <= 2^32 -1 and X > 0
			Hence we do not need scaled_div32() here
			
	VI):    X  =  scaled_div(w_init << 6, R)
			This is safe, since 4380*64*1E6 fit in u64 (worst case with
			R=1 and w_initC80) 
		
	
	VIII) Further simplification
	----------------------------
	Since the constant t_mbi = 64 is a power of two, the following
	simplifications are additionally possible:
		* (s << 6)/t_mbi      can be replaced with s
		* (s << 6)/(2*t_mbi)  can be replaced with s/2
