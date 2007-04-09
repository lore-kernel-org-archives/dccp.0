From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 09 Apr 2007 07:23:59 +0000
Subject: Re: [PATCH 39/43]: Protect against Reset/Sync floods due to buggy applications
Message-Id: <200704090824.00140@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704051637.18198@strip-the-willow>
In-Reply-To: <200704051637.18198@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Eddie,

first of all thank you for help with this bug. 

You are correct, the cause is somewhere else, it was an oversight. 

Arnaldo, can you please ignore this patch (16g); I have withdrawn it from the online directory. 

Instead, 

 * a proper bug fix with description follows;

 * the bug and its cause are documented on 
      http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/seqno_bug/
   (in short, the Sync did not acknowledge GSR, but rather P.seqno);

 * I have further implemented rate-limiting for Syncs as suggested in 7.5.4. Rate-limiting
   proved to be an efficient countermeasure for this bug: it broke the vicious circle of
   invalid-Reset => Sync => invalid Reset. This was because the second received Reset is
   already subject to rate-limiting; hence there is no Sync in reply; hence no further 
   sequence-invalid Reset is triggered. 
   I believe that rate-limiting can be of similiar help in other situations involving 
   sequence-invalid packets.

 * The reason that the bug does not show with the more recent patches is that previously
   it was possible for a DCCP application to silently crash, be killed, terminated without
   its connected peer taking notice of it. Patches 17a and 17b implement an ABORT function
   which sends a DCCP-Reset Code 2 "Aborted" which will terminate the connection. Thus
   mayhem due to half-closed connections is avoided.

Thanks again for pointing this out,
Gerrit
   

Quoting Eddie Kohler:
|  Hi Gerrit,
|  
|  I agree that the bug is scary!  It would be good to fix.  But this fix isn't a 
|  good fix, especially because it makes it trivially easy to shoot down a 
|  connection if you know the port numbers.  Would you mind withdrawing the patch 
|  until the bug reappears?
|  
|  Eddie
|  
|  
|  Gerrit Renker wrote:
|  > Eddie,
|  > 
|  > I have spent half a day or so trying to reconstruct the condition which triggered this bug.
|  > With the new patches regarding closing state I couldn't trigger this bug anymore. Which is
|  > not to say that it has gone away. 
|  > 
|  > All I can say is that I have observed this bug as described and that it is pretty scary -
|  > the computer freezes for several minutes (until the server connection timer declares the
|  > connection as dead) and it generates a massive load of packets. 
|  > 
|  > I will try to follow this up when I have some more time; as indicated by the comment in 
|  > the patch below, I am lacking the resources to implement rate-limiting for DCCP-Sync; too 
|  > many other things to fix.
|  > 
|  > Anyone else any ideas / suggestions?
|  > 
|  > Gerrit
|  > 
|  > 
|  > Quoting Eddie Kohler:
|  > |  Hi Gerrit,
|  > |  
|  > |  I'm surprised this kind of flood happens & think it may represent a bug in the 
|  > |  stack.  What is the acknowledgement number on the Sync packet sent in step 
|  > |  (6)?  It should be GSR, according to Step 6 of the pseudocode in Section 8.5. 
|  > |    If it was GSR, I would expect the following denouement:
|  > |  
|  > |  5. client responds with Reset packet Code 3 with seqno=0
|  > |  6. server thinks that seqno=0 is out of synch (step 6), sends Sync with 
|  > |  seqno=GSS, ackno=GSR, then increments GSS;
|  > |  7. client responds with Reset packet Code 3 with seqno=GSR+1 and ackno=GSS (it 
|  > |  can do this because it takes the seqno from the received packet's ackno, per 
|  > |  Section 8.3.1);
|  > |  8. the Reset is now in synch, so the server kills the connection.
|  > |  
|  > |  No flood should be possible with valid stacks; some people actually verified 
|  > |  this theoretically.
|  > |  
|  > |  Of course stacks can be INvalid, in which case one should rate-limit Syncs, as 
|  > |  allowed by the protocol.
|  > |  
|  > |  Your solution, which is to accept Resets with seqno 0, makes it trivially 
|  > |  simple for an attacker to kill any connection.  It should not be committed! 
|  > |  Can we figure out why the stack has the chatter problem first?
|  > |  
|  > |  Eddie
|  > |  
|  > |  
|  > |  Gerrit Renker wrote:
|  > |  > [DCCP]: Protect against Reset/Sync floods due to buggy applications
|  > |  > 
|  > |  > This patch protects against Reset/Sync floods which happens as a result
|  > |  > of either buggy or crashing client applications. The Reset/Sync flood
|  > |  > is triggered as follows:
|  > |  > 
|  > |  >  1. Client establishes connection to listening server;
|  > |  >  2. before server can write data to client, client crashes;
|  > |  >  3. crashing client removes connection state at client host;
|  > |  >  4. server still thinks client is alive and sends data;
|  > |  >  5. client responds to server packet with Reset packet Code 3, 
|  > |  >     "No Connection", with seqno=0 - as per RFC 4340, 8.3.1;
|  > |  >  6. server thinks that seqno=0 is out of synch (step 6), sends Sync;
|  > |  >  7. goto (6).
|  > |  > 
|  > |  > The result is a drastic flood of packets: In one occasion I counted
|  > |  > 345549 Reset/Sync packets, before the server finally killed itself.
|  > |  > 
|  > |  > Fix:
|  > |  > ----
|  > |  > Since this condition is peculiar and can be distinguished from other
|  > |  > sequence-invalid packets, a special case has been added. The Reset
|  > |  > is accepted if
|  > |  >  * it has Reset Code 3, "No Connection" AND
|  > |  >  * it has sequence number 0 as described in RFC 4340, 8.3.1.
|  > |  > 
|  > |  > If both conditions are satisfied, the Reset is enqueued in the receive queue
|  > |  > as usual, and will very soon terminate the crashed connection.
|  > |  > 
|  > |  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  > |  > ---
|  > |  >  net/dccp/input.c |   17 +++++++++++++++++
|  > |  >  1 file changed, 17 insertions(+)
|  > |  > 
|  > |  > --- a/net/dccp/input.c
|  > |  > +++ b/net/dccp/input.c
|  > |  > @@ -155,6 +155,22 @@ static int dccp_check_seqno(struct sock 
|  > |  >  		    (DCCP_SKB_CB(skb)->dccpd_ack_seq !|  > |  >  		     DCCP_PKT_WITHOUT_ACK_SEQ))
|  > |  >  			dp->dccps_gar = DCCP_SKB_CB(skb)->dccpd_ack_seq;
|  > |  > +
|  > |  > +	} else if (dh->dccph_type = DCCP_PKT_RESET  &&
|  > |  > +		   dccp_hdr_reset(skb)->dccph_reset_code =
|  > |  > +		   DCCP_RESET_CODE_NO_CONNECTION &&
|  > |  > +		   DCCP_SKB_CB(skb)->dccpd_seq = 0) {
|  > |  > +		/*
|  > |  > +		 * This happens when connection is established and client app
|  > |  > +		 * crashes before server can send data. The crashing client
|  > |  > +		 * removes connection state, so the server gets a Code 3 Reset
|  > |  > +		 * packet with seqno 0 (RFC 4340, 8.3.1). Responding here with
|  > |  > +		 * a Sync leads to a Reset-Storm which will flood the network
|  > |  > +		 * until the server gives up on this connection or is killed.
|  > |  > +		 * We let this case pass so that the Reset gets enqueued and
|  > |  > +		 * will terminate the erratic connection.
|  > |  > +		 */
|  > |  > +		DCCP_WARN("DCCP: Peer sent RESET with seqno 0\n");
|  > |  >  	} else {
|  > |  >  		DCCP_WARN("DCCP: Step 6 failed for %s packet, "
|  > |  >  			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
|  > |  > @@ -168,6 +184,7 @@ static int dccp_check_seqno(struct sock 
|  > |  >  			  (unsigned long long) lawl,
|  > |  >  			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_ack_seq,
|  > |  >  			  (unsigned long long) dp->dccps_awh);
|  > |  > +		/* FIXME: Rate-limit DCCP-Sync packets as per RFC 4340, 7.5.4 */
|  > |  >  		dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq, DCCP_PKT_SYNC);
|  > |  >  		return -1;
|  > |  >  	}
|  > |  > -
|  > |  > To unsubscribe from this list: send the line "unsubscribe dccp" in
|  > |  > the body of a message to majordomo@vger.kernel.org
|  > |  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  > |  
|  > |  
|  
|  
