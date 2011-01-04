From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 04 Jan 2011 11:47:59 +0000
Subject: Re: Sequence Number Validation Bug Fixes 2/2
Message-Id: <20110104114759.GB3566@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1293393024.22785.1.camel@jero-laptop>
In-Reply-To: <1293393024.22785.1.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | + if(after48(seqno, dp->dccps_gsr)){
| > | + dccp_update_gsr(sk, seqno);
| > | + }
| > | 
| > | if (dh->dccph_type != DCCP_PKT_SYNC &&
| > |     ackno != DCCP_PKT_WITHOUT_ACK_SEQ && 
| > 
| > I would like to move that change from dccp_check_seqno() into
| > dccp_update_gsr(), since the latter function is also called for Sync/SyncAck
| > packets, where the same problem exists.
| 
| In the case of Sync/SyncAck packets, RFC 4340 section 7.5.4 requires
| that:
| "On receiving a sequence-valid DCCP-Sync packet, the peer endpoint
| (say, DCCP B) MUST update its GSR variable and reply with a DCCP-
| SyncAck packet.  The DCCP-SyncAck packet's Acknowledgement Number
| will equal the DCCP-Sync's Sequence Number, which is not necessarily
| GSR.  Upon receiving this DCCP-SyncAck, which will be sequence-valid
| since it acknowledges the DCCP-Sync, DCCP A will update its GSR
| variable, and the endpoints will be back in sync."
| 
| Adding the check for > GSR inside dccp_update_gsr() breaks this
| requirement.
| 
I wonder how the requirement breaks, in the above paragraph are several points:
 1. it applies only to sequence-valid DCCP-Sync packets,
 2. need to clarify what "update its GSR variable" means,
 3. DCCP-SyncAck.ackno = DCCP-Sync.seqno (illustrated below),
 4. case for receiving sequence-valid DCCP-SyncAck analogous to (1), (2).

| Further, Sync/SyncAck packets are already checked for sequence validity
| by dccp_check_seqno() before the call to dccp_update_gsr(). The checks
| used follow RFC 4340 section 7.5.3:
| DCCP-Sync        SWL <= seqno             AWL <= ackno <= AWH
| DCCP-SyncAck     SWL <= seqno             AWL <= ackno <= AWH
| 
Yes, I think you refer to step 5 in dccp_check_seqno(), so (1) holds.

Following sketch with (seqno, ackno) packets:

      receiver                               sender
          |                                    |
  packet  |   DCCP-packet(SND.GSS, P.ackno)    |
  invalid +<-----------------------------------|
          |                                    |
          |   DCCP-Sync(RCV.GSS, SND.GSS)      |
          |----------------------------------->+  passes: ackno = SND.GSS = AWH
          |                                    |  set GSR := RCV.GSS (see below)
   OK (*) |   DCCP-SyncAck(SND.GSS, RCV.GSS)   |  set SND.GSS := SND.GSS + 1
   update +<-----------------------------------|
   GSR    |                                    |
          |   DCCP-packet(RCV.GSS+1, SND.GSS)  |  
          |----------------------------------->+

   (*) The SyncAck passes because SWL <= SND.GSS
                          and     AWL <  RCV.GSS = AWH.


With regard to (2), my understanding is that "updating the GSR" or "updating
the GAR" (step 6 in RFC 4340, 8.5) means to update the value if it is greater
than the previous one but not otherwise.

Both variables are defined in terms of 'Greatest' in 7.1, so allowing a
(reordered) packet to reduce these values would be against their definition.

This was the reason for the bug fix on 23 Nov, and I think the same principle
applies here. There are only two cases to consider:

 a) GSR <= seqno 
    This is the expected case, seqno = RCV.GSS is higher than all received
    sequence numbers before.

 b) GSR > seqno
    Due to (1) we have SWL <= seqno < GSR. Due to the adjustment at the end
    of 7.5.1, we further have
    ISR <= SWL = max(GSL + 1 - floor(W/4), ISR) <= seqno < GSR, shorter
    ISR <= seqno < GSR. This means that the seqno on the Sync(Ack) packet
    is below the Greatest Sequence Number Received on the same connection.

    Since per 4.2, "Every DCCP packet increments the sequence number", there
    are only pathological cases where this condition could occur:
    * a delayed DCCP-Sync(Ack) that had been sent earlier,
    * a stray packet from an earlier incarnation of the same connection
      (having the same src/dst port numbers and service code),
    * a sequence number attack.

    For the first case, refer to above figure:
     i) DCCP-Sync: since GSR > seqno, the value of RCV.GSS used in the
        Sync packet is less than the current GSS = AWH at the receiver.
	The SyncAck would pass the [AWL, AWH] test if the difference is
        not too big. A similar problem arises when the Sync(Ack) handshake
        succeeds, and packets arrive from the receiver: the GSS in the packet
	will have a distance > 1 from the one used for the Sync.
    ii) DCCP-SyncAck: I believe this is not possible. If the Sync was sent
        since P.ackno < RCV.AWL = RCV.GSS - W' + 1 then how could the sender
        in the meantime learned a better value for P.ackno other than another
        Sync(Ack) handshake?
        Otherwise, if the Sync was sent due to a failed test for SND.GSS, it
	means that either SND.GSS < SWL <= GSR or SND.GSS > SWH > GSR, where
	the first condition does not apply for packets sent from ISR ... GSR.
	But the second condition contradicts the assumption that seqno < GSR.

    The second case is an exception, due to the Quiet Time in 7.3. The third
    case benefits from not updating the GSR towards lower values, since not
    only would moving GSR backwards help to get the connection out of sync, 
    but it also makes it a bit more difficult to guess valid sequence numbers
    in a DCCP-Sync attack (7.5.5).

In short, I find that allowing DCCP-Sync(Ack) to move the GSR backwards to
sequence number below those already received on acknowledgeable packets on
the same connection creates a complex and counter-intuitive bevaviour which
I think is not warranted (in particular the definition of GSR does no longer
mean 'Greatest', but would change into something like "usually the greatest
sequence number received, when a DCCP-Sync arrives, GSR could be up to W/4
below the greatest sequence number received on the connection").

Lastly, there was another reason for moving the check into dccp_update_gsr():
it is legitimate at any stage during the connection to send a DCCP-Sync. This
is currently used if the packet real estate becomes to small for CCID-specific
options (dccps_sync_scheduled > 0). 

In the sense of 6.6.1 this is in future also planned to update feature values
on an established connection: Sequence Window and Ack Ratio are the only
currently known NN options, for which such a dynamic update would make sense.

Moving the check for GSR into dccp_update_gsr() allows to put the new value
for the feature-remote Sequence Window into the [SWL, SWH] window, as it is
for instance called by dccp_hdlr_seq_win().

Please let me know your thoughts, as said I am not going to submit this at this
stage (it is however in the test tree at the moment).

Gerrit

| > >>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
| > dccp: fix bug in updating the GSR
| > 
| > Currently dccp_check_seqno allows any valid packet to update the Greatest
| > Sequence Number Received, even if that packet's sequence number is less than
| > the current GSR. This patch adds a check to make sure that the new packet's
| > sequence number is greater than GSR.
| > 
| > Signed-off-by: Samuel Jero <sj323707@ohio.edu>
| > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
| > ---
| >  net/dccp/dccp.h |    3 ++-
| >  1 file changed, 2 insertions(+), 1 deletion(-)
| > 
| > --- a/net/dccp/dccp.h
| > +++ b/net/dccp/dccp.h
| > @@ -426,7 +426,8 @@ static inline void dccp_update_gsr(struc
| >  {
| >  	struct dccp_sock *dp = dccp_sk(sk);
| >  
| > -	dp->dccps_gsr = seq;
| > +	if (after48(seq, dp->dccps_gsr))
| > +		dp->dccps_gsr = seq;
| >  	/* Sequence validity window depends on remote Sequence Window (7.5.1) */
| >  	dp->dccps_swl = SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_win / 4);
| >  	/*



-- 
