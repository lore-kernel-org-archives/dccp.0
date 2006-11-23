From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 23 Nov 2006 13:02:44 +0000
Subject: Conditions when t_ipi, t_nom, t_delta need to be recalculated
Message-Id: <200611231302.45475@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

    
	  "When is it necessary to update t_ipi, t_delta, t_nom"  ?
          =============================

 Following Ian's email from yesterday, I spent time working through the RFCs and 
 compiled information about the dependencies among the different parameters. This
 email is a write-up of what I found and serves as basis for subsequent patches.

 The parameters are:

 s:  sender packet size in bytes,         known to sender
 X:  current sending rate (bytes/second), known to sender

 p     :  loss event rate,                undefined until feedback has been received
 t_RTT :  round-trip time estimate,       undefined until feedback has been received
 t_RTO :  retransmission timeout,         undefined until feedback has been received
 X_calc:  = f(s, p, t_RTT) - also         undefined until feedback has been received
 X_inst:  instantaneous xmit rate, f(X) - undefined until feedback has been received

 t_nfb: nofeedback time-out,              known to sender
 t_tld: time-last-doubled,                -1 until first packet has been sent


1) Definition of t_ipi
----------------------
 In [RFC 3448, 4.6], t_ipi is defined as          t_ipi = s/X_inst

 If the feature `Preventing Oscillations' [RFC 3448, 4.5] is not implemented, then X_inst = X.
 Otherwise, X_inst depends on the feedback sample for t_RTT and is undefined until the first feedback
 has arrived. The assumption here is that the optional `Preventing Oscillations' feature is not 
 implemented, as it requires square-root computation which is complicated without floating-point
 arithmetic. Then,
			t_ipi = s/X

 and X can be (1) the initial value or (2) the recalculated value after feedback has been received.
 Hence t_ipi needs to be updated whenever
		(i)   s changes
		(ii)  X changes
 To simplify, we assume that `s' is fixed and therefore t_ipi only needs to be updated whenever X changes.
 However, in the actual patch (which tracks the mean value of the packet size in `s'), a note will be added
 as a possibility for further optimisation (it is also not implemented since the standard is silent about 
 whether the t_ipi should be updated whenever the mean value `s' changes). 


2) What depends on t_ipi
------------------------
 The following values are derived from and thus depend on t_ipi   [RFC 3448, 4.6]:

    * nominal sending time:    t_nom    =  t_(i+1) + t_ipi           
    * scheduling delta    :    t_delta  =  min(t_ipi/2, t_gran/2)

 Another dependency is the nofeedback timer: after initial feedback has been received, it is set to 

     		                t_nfb   =   max(4*t_RTT, 2 * s/X)   
                                        =   max(4*t_RTT, 2 * t_ipi)
 
 Thus these three values, in turn, need to be updated when t_ipi changes. 


3) Initial values
-----------------
 Initial settings are described in [RFC 3448, 4.2]:
 	 X/s = 1hz
 	 t_RTT, t_RTO are undefined
 	 t_tld = -1
 Thus we have the following initial values:
 	 t_ipi = s/X = 1 second
 	 t_nom = t_now + t_ipi  
 	 t_delta = t_gran/2        (since OS schedules finer than 1 second)

 ==> A patch has already been sent for this case.


4) Sending until the first feedback packet arrives
--------------------------------------------------
 No need to update: X, t_ipi, t_delta, t_nfb stay at their values, t_nom is incremented in the manner
          t_nom += t_ipi            [where t_ipi remains constant]

 => This is already implemented by ccid3_hc_tx_send_packet


5) When the first feedback packet arrives
-----------------------------------------
 The first feedback packet sent by a receiver has p = X_recv = 0 [RFC 3448, 6.3]. Plugging these values
 into step (4) of [RFC 3448, 4.3] and considering t_tld = -1, gives

            X = max(2 * min(X, X_recv), s/R)
              = max(2 * min(X, 0), s/R)      = s/R

 Without modification, the first sending rate remains at 1 packet per round-trip time. [RFC 4342, sec. 5] 
 increases this to 2 * s/R, up to the maximum of 4 packets per RTT and 4380 per RTT (this assumes that MSS-sized
 packets are sent).

 ==>  A patch is required to consider this special case.


6) When the second ... n-th feedback arrives
-------------------------------------------- 
  X, t_ipi, t_delta, t_nfb, t_nom need to be updated. 

 ==> This is already handled by ccid3_hc_tx_packet_recv.


7) When the nofeedback timer expires and no feedback has been received so far (step 4.4)
----------------------------------------------------------------------------------------
  X      = max(X/2, s/t_mbi) 

  --> t_ipi, t_nom, t_delta must be recalculated 

  t_nfb  = max(4*t_RTT, 2*t_ipi)

  ==> This needs updating, there is a FIXME in ccid3_hc_tx_no_feedback_timer at this place.


8) When the nofeedback timer expires and feedback has been received previously (step 4.4)
-----------------------------------------------------------------------------------------
  * t_RTT, t_RTO, and p do not change with regard to the last-received feedback
  * thus X_calc is as before
  * X_recv gets changed
  * hence X gets changed as a result of step (4) of [RFC 3448, 4.3]
  --> t_ipi, t_nom, t_delta, and t_nfb need to be updated

  ==> This also needs a patch, since X is updated, but t_ipi, t_nom, and t_delta are not
