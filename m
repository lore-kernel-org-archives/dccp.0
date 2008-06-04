From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 04 Jun 2008 15:44:52 +0000
Subject: Re: [PATCH - test-tree] DCCP: Increment sequence number on
Message-Id: <20080604154452.GB4625@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <4846462F.3020004@cn.fujitsu.com>
In-Reply-To: <4846462F.3020004@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Jun 04, 2008 at 02:38:49PM +0100, Gerrit Renker escreveu:
> Quoting Arnaldo:
> | Em Wed, Jun 04, 2008 at 03:37:19PM +0800, Wei Yongjun escreveu:
> | > When retransmit the first REQUEST, the sequence number does not be  
> | > increased. This is because before retransmit the first REQUEST packet,  
> | > the icsk->icsk_retransmits is 0, so dccp_transmit_skb() will fetch the  
> | > dp->dccps_iss as the retransmit sequence number.
> | >
> | > This patch fix the problem.
> | 
> | Looks like a hack, ugh. Proper fix must be not bumping it on
> | dccp_transmit_skb when the packet is a REQUEST, no?
> | 
> Yes, correct, it is a hack. I was working on that until one hour ago
> and then decided to put it aside. The fix is in the test tree for now
> but is not meant to remain there.
> 
> The problem is that, for the three retransmittable packet types in DCCP
> (Close, CloseReq, Request), there is no obvious way of distinguishing
> the original packet from the cloned packet.

But why do you have to? If it is a REQUEST, don't bump the GSS... wait,
I actually took the time and went to re-read the RFC and I think the
changelog Wei wrote is misleading, as:

-------------------- 8< ------------------------------------------------
   A client in the REQUEST state SHOULD use an exponential-backoff timer
   to send new DCCP-Request packets if no response is received.  The
   first retransmission should occur after approximately one second,
   backing off to not less than one packet every 64 seconds; or the



Kohler, et al.              Standards Track                    [Page 58]
^L
RFC 4340      Datagram Congestion Control Protocol (DCCP)     March 2006


   endpoint can use whatever retransmission strategy is followed for
   retransmitting TCP SYNs.  Each new DCCP-Request MUST increment the
   Sequence Number by one and MUST contain the same Service Code and
   application data as the original DCCP-Request.
-------------------- 8< ------------------------------------------------

So the fix would be for not bumping GSS on the first packet? I guess so,
the flow is:

To create a socket:

 dccp_v4_connect(): sets iss
   dccp_connect()
     dccp_connect_init(): iss = gss
     dccp_transmit_skb: gss += 1

So the problem is that if this is the first packet being sent on a
connection we should not do the gss += 1...

> Here is the sketch of the solution I was working on, I'd be glad for input:
>  * dccp_entail(), skb_clone(), dccp_transmit_skb() and setting of the icsk
>    retransmit timer always occur together;
>  * as soon as skb_clone() is called, skb->cloned is true;
>  * so the idea is to 
>    - use dccp_transmit_skb() to transmit the un-cloned skb;
>    - sk->send_head = skb_clone(skb, gfp_any())
>    - need some more careful analysis, but I think the set_owner_w() can
>      also be removed, needs checking against the WARN_ON in
>      dccp_transmit_skb().
> 
> Or maybe there is an easier way - the objective is to have a clear
> indicator whether the skb is a retransmitted one or the first one
> (since a similar problem arises when sending Close(Req) packets).

...since I think I got to the same page as you guys... :-) Lets continue
from this point:

I think we have to use set_owner_w, its safer, we better get the
connection stuck due to using all its socket send buffer space if the
packet is never freed because of some stack bug than to get the whole
machine with a problem, even if after a long time, if we leak these
packets.

Perhaps we can use a flag in skb->cb that we would set only on the first
packet? Nah, I think we should have a __dccp_transmit_skb, that... code,
lets show it as a patch, see at the end of this message.

WRT Close(Req) I think it is right as it is, i.e. we should bump GSS, if
not we'll send the packet with the same sequence number as the last
packet sent, i.e. the problem is just on the very first packet.

Or am I missing something?

- Arnaldo

diff --git a/net/dccp/output.c b/net/dccp/output.c
index 1f8a9b6..3110df1 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -39,7 +39,7 @@ static void dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
  * IP so it can do the same plus pass the packet off to the
  * device.
  */
-static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
+static int __dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 {
 	if (likely(skb != NULL)) {
 		const struct inet_sock *inet = inet_sk(sk);
@@ -54,8 +54,6 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 		int err, set_ack = 1;
 		u64 ackno = dp->dccps_gsr;
 
-		dccp_inc_seqno(&dp->dccps_gss);
-
 		switch (dcb->dccpd_type) {
 		case DCCP_PKT_DATA:
 			set_ack = 0;
@@ -132,6 +130,12 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 	return -ENOBUFS;
 }
 
+static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
+{
+	dccp_inc_seqno(&dccp_sk(sk)->dccps_gss);
+	__dccp_transmit_skb(sk, skb);
+}
+
 /**
  * dccp_determine_ccmps  -  Find out about CCID-specfic packet-size limits
  * We only consider the HC-sender CCID for setting the CCMPS (RFC 4340, 14.),
@@ -472,7 +476,7 @@ int dccp_connect(struct sock *sk)
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST;
 
 	dccp_skb_entail(sk, skb);
-	dccp_transmit_skb(sk, skb_clone(skb, GFP_KERNEL));
+	__dccp_transmit_skb(sk, skb_clone(skb, GFP_KERNEL));
 	DCCP_INC_STATS(DCCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the REQUEST until an answer. */
