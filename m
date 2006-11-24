From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:19:04 +0000
Subject: [PATCH 0/10] [RFC]: CCID 3 updates
Message-Id: <200611241619.04691@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have cut this into 10 small pieces to make reviewing easier. 

If everyone is happy with it, I can re-send it as one piece.

I have compile-tested all patches but I think CCID 3 needs some more
(other) work and then some performance-testing. 

Patch  1: Avoid congestion control on zero-sized data packets.
          Sending zero-sized Data/DataAck packets is theoretically possible, 
          but just makes trouble for CCID 3. This patch changes the error
          code and removes one message which always gets printed.

Patch  2: Remove redundant statements in ccid3_hc_tx_packet_sent.
          An analysis showed that one statement can be removed.

Patch  3: Resolves a small FIXME (Acks when nothing has been sent).

Patch  4: Consolidate timer resets.
          This considers calculating the nofeedback timeout when no feedback
          has previously been received. It applies common sense, since RFC 3448
          is not clear about this case (it recommends to use max(4*R, 2*s/X), but
          R is still undefined due to section 4.2)

Patch  5: Consistently update t_nom, t_ipi, t_delta.
          This, like the other patches, results from the earlier analysis and
          exploits the dependencies among variables.

Patch  6: Consolidate handling of t_RTO.
	  This updates several things related to t_RTO and nofeedback timeout,
          exploiting yet another dependency.
	  And it adds a FIXME: currently the way it is calculated is non-standard.
          The code does t_RTO              = max(4*R, 1 second)
                        nofeedback_timeout = max(t_RTO, 2 * s/X)
          (RFC 3448:    nofeedback_timeout = max(4 * R, 2 * s/X) )
          I have asked my colleague about it - is it good or bad to keep it this way???
        
Patch  7: Avoid `division by zero' errors.
          This adds the protection against dividing a zero RTT for the sender.
          I believe that this could be further improved - with regard to malfunctioning
          timestamps.
          
Patch  8: Larger initial windows.
          This implements the larger-initial-windows feature for CCID 3, as per [RFC 4342, 5.]

Patch  9: Add documentation for the TFRC structure fields (in include/linux/tfrc.h).
          ==> Here I have a suggestion. 
               The only, single source code file 
               which currently includes          include/linux/tfrc.h
               is                                net/dccp/ccids/lib/tfrc_equation.c
               Maybe it would be a good
               idea to merge                     include/linux/tfrc.h
               with                              net/dccp/ccids/lib/tfrc.h
               (also included by                 net/dccp/ccids/lib/tfrc_equation.c ),
               since                             net/dccp/ccids/lib/tfrc.h
               is currently almost empty ???

Patch 10: Simplify dccp_rcv_state_process.
          This adds a minor simplification in the control flow.


-- Gerrit
