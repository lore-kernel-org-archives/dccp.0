From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 29 Nov 2006 15:15:46 +0000
Subject: CCID 3: Strategy for removing division bugs and division errors
Message-Id: <200611291515.46613@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As promised, I sat down and wrote up conditions and current problems with
some of the calculations in the CCID 3 module. Changes are required only for the sender.

In a nutshell, the strategy solves
 * the problem that dividing-by-seconds is not handled correctly
 * defines a sufficient resolution for tracking sending rates
 * gets rid of the overflow problem 

The cost is that 
 * at least 1 and ideally 3 structure elements of tfrc_tx_info make it to __u64
 ==> Arnaldo are you OK with this?

but this has the advantage of tackling both overflow and the missing resolution of
lower send rates.

The detailed derivation is below, I am putting this into patches at the moment. It
would be good to have this codified before Ian starts testing. 


       Reasonable assumptions for and a corresponding scheme for the calculation of CCID 3 rates
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


 Problem:
 ====
  The CCID 3 specification uses bytes, seconds, and bytes/second as units. Additionally, the
  timestamp options (Timestamp, Timestamp Echo, and Elapsed Time) require a representation of time
  in units of 10 * microseconds. The kernel internally uses microseconds to represent time. 
  This results in many divisions of the type `s * 1E6 / t' where s is a packet size in bytes and
  t is a time unit in microseconds. 

  (a) Problem 1: Overflow
      -------------------
      Since currently receive/sending rates are stored as u32, this leads to overflow. 
      There are several  ways of tackling this:
             * the patch by Nishida-san implements a subset of rational arithmetic where
               all numbers are expressed as a 
                           struct  fix-point { long long num; 
                                              long long denom;
                           }; 
                The problem with this is that it has to be carried through for each single
                elementary operation (+,-,*,=,>,<,/,%), which is messy.

             * the current Linux implementation uses a function 

                       usecs_div(u32 a, u32 b)   =    a * 1E6 / b

               which computes a divisor in such a way that u32 overflow is avoided for a. 
               While this goes a some way towards avoiding overflow, it comes at a price: 
                   since a piecewise-linear function is used, a constant is substituted
                   for many different values. The result is a substantial computation error 
                   - this can be as high as 100% (I have a proof and test program). 


  (b) Problem 2: What to do with non-microsecond time units
      -----------------------------------------------------
      There are a few computations and constants in RFC 3448 and RFC 4342 which are not based
      on microsecond time units. The following table lists these    

      s/t_mbi			4.3	bytes/second		0 if s < 64
      s/(2*t_mbi)		4.4	bytes/second		0 if s < 32
      X_recv = X_calc/4		4.4	bytes/second		0 if X_calc < 4 bytes/second
      X/2			4.4	bytes second

      These expressions are currently not handled correctly - this is a BUG in CCID 3. 
      
 Solution:
 ====  A brute-force idea is to scaled everything by 1E6 and use bytes/microsecond (or 1e6 bytes/second)
  as basis for sending rates. But this introduces overflow for many calculations - even on 64 bit.

  i)  Minimal granularity for sending/receiving rate
  --------------------------------------------------
      A high granularity is not necessary:
	
        * [RFC 3448, 4.3] specifies the minimum sending rate as 1 packet in 64 seconds

        * the packet size `s' is never smaller than 1 byte 
                             and never larger than  2^32 - 1  (4 GByte), since this is 
            (a) the largest size of an IPv6 jumbogram (RFC 2765) and
            (b) the type limit of the current representation
        * hence,
			1/64  <=    X   <= 2^32 - 1 
      
      It is therefore fully sufficient to store X (X_recv, X_calc) in units of 64bytes/second.
      Internet speeds are growing fast, having a resolution of speeds higher than 1/64 is thus
      a truly wasted effort. 

 ii)  Implications for storage size
 -----------------------------------
      Currently X, X_calc, X_recv are all stored as u32. Due to the above this is no longer 
      sufficient: we are now at least 6 bits short.
 
        * the receiver does not necessarily need a modification since it sends X_recv as u32 anyway

        * at the sender it is however better to scale all X quantities. It is like enlarging a
          picture - everything needs to keep its proportions.

        * hence the changes will look like:
            struct tfrc_tx_info {
			__u64 tfrctx_x;			/* this is really required */
			__u64 tfrctx_x_recv;		/* would be better to have as 64-bit */
			__u64 tfrctx_x_calc;		/* 	ditto 		   */
			/* ... */
	     };

        * the advantages are that
               (a) usecs_div is now much simpler
               (b) it would mean a headache and a mess (but it is possible) to keep the sending
                   rate in different sizes (scaled/unscaled); but with the above we don't need to
               (c) u64 is sufficient even when scaling both by 64 and by 1E6

 iii) Implications for algorithm
 -------------------------------
      This is a clerical job but needs to be done systematically: at the sender, all operations 
      and comparisons have to be changed with regard to the scaled format. This is now done below.
      For the receiver, no changes are required.
     
      * Initialisation [RFC 3448, 4.2]
          Set X to 64 * 1 packet / second   (i.e. X = s << 6)

      * Sender behaviour when feedback is received [RFC 3448, 4.3 - step (4)]

          => When X_recv is computed set
            X_recv = hctx->packet_options_x_recv << 6;

          If (p > 0) {
            X_calc = calcX(R, s, p);             /* we leave that as it is for the moment */
            X_calc << 6;                         /* scale by 64                           */
            X  =  max(min(X_calc, 2*X_recv),     /* X_recv is also scaled */
                      (s << 6) / t_mbi)     );   /* now it is correct     */   
          
          } Else If(t_now - tld >= R) {
               X   = max(2 * min(X, X_recv), scaled_div(s << 6, R);    /* now also works */
               tld = t_now
          } 
          
          Where the analogue of usecs_div now is renamed into:

               u64 scaled_div(u64 size, u32 time)  { return (size * 1000000) / time; }

        => step (5): the nofeedback timer now expires in 
            
               max(4 * R, 2 * scaled_div(s, X >> 6))     /* to obtain microseconds */
           
            This use is why I would like to suggest a renaming into scaled_div - we are not
            dividing by microseconds here.

      * Expiration of nofeedback timer [RFC 3448, 4.4]

        (a) If the sender already has got some feedback:

              If (X_calc > 2 * X_recv)                          /* comparison is in proportion */
                  X_recv = max(X_recv/2, (s << 6)/(2*t_mbi));   /* now works as expected */
              Else                    
                  X_recv = X_calc/4
               
              => expire the nofeedback timer after 
                  max(4 * R, 2 * scaled_div(s, X >> 6))         /* to obtain microseconds */

        (b) If the sender does not yet have any feedback then

              X = max(X/2, (s << 6)/t_mbi)                      /* now also works as expected */

              => expire the nofeedback timer after 2 seconds


      * Preventing oscillations [RFC 3448, 4.5]

        This is currently not supported, but the solution is forward-compatible, since the scaled
        X can be kept as it is.

      * Scheduling of Packet Transmissions [RFC 3448, 4.6]
        
	        t_ipi   =   scaled_div(s, X >> 6)              /* yes, microseconds */
      
      * Larger initial windows [RFC 4342, sec. 5]
        
                w_init = min(4 * s, max(2 * s, 4380))
                X      = scaled_div(w_init << 6, R)


That's all !
