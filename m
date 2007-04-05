From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 05 Apr 2007 17:02:23 +0000
Subject: Re: [PATCH 39/43]: Protect against Reset/Sync floods due to buggy
Message-Id: <46152B9F.9090806@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200704051637.18198@strip-the-willow>
In-Reply-To: <200704051637.18198@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit,

I'm surprised this kind of flood happens & think it may represent a bug in the 
stack.  What is the acknowledgement number on the Sync packet sent in step 
(6)?  It should be GSR, according to Step 6 of the pseudocode in Section 8.5. 
  If it was GSR, I would expect the following denouement:

5. client responds with Reset packet Code 3 with seqno=0
6. server thinks that seqno=0 is out of synch (step 6), sends Sync with 
seqno=GSS, ackno=GSR, then increments GSS;
7. client responds with Reset packet Code 3 with seqno=GSR+1 and ackno=GSS (it 
can do this because it takes the seqno from the received packet's ackno, per 
Section 8.3.1);
8. the Reset is now in synch, so the server kills the connection.

No flood should be possible with valid stacks; some people actually verified 
this theoretically.

Of course stacks can be INvalid, in which case one should rate-limit Syncs, as 
allowed by the protocol.

Your solution, which is to accept Resets with seqno 0, makes it trivially 
simple for an attacker to kill any connection.  It should not be committed! 
Can we figure out why the stack has the chatter problem first?

Eddie


Gerrit Renker wrote:
> [DCCP]: Protect against Reset/Sync floods due to buggy applications
> 
> This patch protects against Reset/Sync floods which happens as a result
> of either buggy or crashing client applications. The Reset/Sync flood
> is triggered as follows:
> 
>  1. Client establishes connection to listening server;
>  2. before server can write data to client, client crashes;
>  3. crashing client removes connection state at client host;
>  4. server still thinks client is alive and sends data;
>  5. client responds to server packet with Reset packet Code 3, 
>     "No Connection", with seqno=0 - as per RFC 4340, 8.3.1;
>  6. server thinks that seqno=0 is out of synch (step 6), sends Sync;
>  7. goto (6).
> 
> The result is a drastic flood of packets: In one occasion I counted
> 345549 Reset/Sync packets, before the server finally killed itself.
> 
> Fix:
> ----
> Since this condition is peculiar and can be distinguished from other
> sequence-invalid packets, a special case has been added. The Reset
> is accepted if
>  * it has Reset Code 3, "No Connection" AND
>  * it has sequence number 0 as described in RFC 4340, 8.3.1.
> 
> If both conditions are satisfied, the Reset is enqueued in the receive queue
> as usual, and will very soon terminate the crashed connection.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/input.c |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> --- a/net/dccp/input.c
> +++ b/net/dccp/input.c
> @@ -155,6 +155,22 @@ static int dccp_check_seqno(struct sock 
>  		    (DCCP_SKB_CB(skb)->dccpd_ack_seq !>  		     DCCP_PKT_WITHOUT_ACK_SEQ))
>  			dp->dccps_gar = DCCP_SKB_CB(skb)->dccpd_ack_seq;
> +
> +	} else if (dh->dccph_type = DCCP_PKT_RESET  &&
> +		   dccp_hdr_reset(skb)->dccph_reset_code =
> +		   DCCP_RESET_CODE_NO_CONNECTION &&
> +		   DCCP_SKB_CB(skb)->dccpd_seq = 0) {
> +		/*
> +		 * This happens when connection is established and client app
> +		 * crashes before server can send data. The crashing client
> +		 * removes connection state, so the server gets a Code 3 Reset
> +		 * packet with seqno 0 (RFC 4340, 8.3.1). Responding here with
> +		 * a Sync leads to a Reset-Storm which will flood the network
> +		 * until the server gives up on this connection or is killed.
> +		 * We let this case pass so that the Reset gets enqueued and
> +		 * will terminate the erratic connection.
> +		 */
> +		DCCP_WARN("DCCP: Peer sent RESET with seqno 0\n");
>  	} else {
>  		DCCP_WARN("DCCP: Step 6 failed for %s packet, "
>  			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
> @@ -168,6 +184,7 @@ static int dccp_check_seqno(struct sock 
>  			  (unsigned long long) lawl,
>  			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_ack_seq,
>  			  (unsigned long long) dp->dccps_awh);
> +		/* FIXME: Rate-limit DCCP-Sync packets as per RFC 4340, 7.5.4 */
>  		dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq, DCCP_PKT_SYNC);
>  		return -1;
>  	}
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
