From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 14:00:18 +0000
Subject: [PATCH 10/17] [DCCP]: calling dccp_v{4,6}_reqsk_send_ack is a BUG
Message-Id: <200610241500.19032@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

[DCCP]: calling dccp_v{4,6}_reqsk_send_ack is a BUG

This patch removes two functions, the send_ack functions of request_sock, w=
hich are not called/used
by the DCCP code. It is correct that these functions are not called, below =
is a justification why
calling these functions (on a passive socket in the LISTEN/RESPOND state) w=
ould mean a DCCP protocol
violation.


A) bACKground: using request_sock in TCP:
-----------------------------------------
        req->rsk_ops->send_ack is called only once, in tcp_check_req() of n=
et/ipv4/tcp_minisocks.c
        This single case deals with a socket in the SYN-RECEIVED state; RFC=
 793 on page 69 describes
        the case for SYN-RECEIVED and other states: "If an incoming segment=
 is not acceptable, an
        acknowledgment should be sent in reply (unless the RST bit is set, =
if so drop the segment
        and return):
                       <SEQ=3DSND.NXT><ACK=3DRCV.NXT><CTL=ACK>"
     =20
        ( SND.NXT =3D ISS + 1, RCV.NEXT =3D SEG.SEQ + 1 if SYN-RECEIVED was=
 entered from LISTEN)

       This is referenced by the following code segment:
     =20
        if (paws_reject || !tcp_in_window(...)) {
                /* Out of window: send ACK and drop. */
                if (!(flg & TCP_FLAG_RST))
                        req->rsk_ops->send_ack(skb, req);
                /* ... */
                return NULL;
        }
       =20
        This is the _only_ occurrence where rsk_ops->send_ack() is called f=
or TCP.

B) The Problem: protocol constraints of DCCP:
---------------------------------------------
        (1) rsk_ops->send_ack is called _nowhere_ throughout the DCCP code =
(grep confirms)
        (2) This is correct, due to the following:
                (a) RFC 4340, sec. 8.5, step 3: The only acceptable packets=
 in LISTEN state
                    are DCCP-Request or packets with a valid InitCookie opt=
ion (InitCookie
                    is an optional, not mandatory, protocol feature). Only =
if such a packet
                    arrives, RESPOND is entered after sending a DCCP-Respon=
se.=20
                    Then,  in step 11, receiving any packet other than DCCP=
-Request, will
                    trigger the transition to OPEN (`Established') =3D> the=
 request_sock
                    will become a full socket here.=20
                (b) DCCP uses the Sync where TCP would use an ACK - in the =
case of
                    sequence-invalid packets (RFC 4340, 7.5.4). This howeve=
r is already handled
                    by calling dccp_send_sync in dccp_check_seqno(),__dcp_r=
cv_established(),=20
                    dccp_rcv_state_process(), dccp_rcv_closereq().=20
               =20
c) Conclusion:
--------------
        In DCCP the function pointer send_ack of struct request_sock_ops is=
 not necessary,
        and calling it would mean a protocol violation. The DCCP code is co=
rrect in this regard
        in that it does not call the send_ack virtual function pointer, but=
 the existence of two
        functions - which are never called and are not necessary - is highl=
y confusing.
        Therefore, the attached patch replaces the functions with a verbose=
 message (if debugging
        is enabled), and otherwise flags a BUG().=20
        This solution preserves the generic structure of the request_sock w=
hile making sure that
        RFC 4340 is not violated by the implementation.


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
---------------------------------------------------------------------------=
---

 net/dccp/dccp.h |    5 ++++
 net/dccp/ipv4.c |   48 -----------------------------------------------
 net/dccp/ipv6.c |   57 ---------------------------------------------------=
-----
 3 files changed, 7 insertions(+), 103 deletions(-)

---------------------------------------------------------------------------=
---

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f294b89..646a0c3 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -130,6 +130,11 @@ extern int  dccp_retransmit_skb(struct s
=20
 extern void dccp_send_ack(struct sock *sk);
 extern void dccp_send_delayed_ack(struct sock *sk);
+static inline void dccp_reqsk_send_ack(struct sk_buff *s,struct request_so=
ck *r)
+{
+       BUG();          /* ACK packets are never sent in LISTEN/RESPOND sta=
te */
+}
+
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
 			   const enum dccp_pkt_type pkt_type);
=20
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7690c83..89b7306 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -193,52 +193,6 @@ static inline void dccp_do_pmtu_discover
 	} /* else let the usual retransmit timer handle it */
 }
=20
-static void dccp_v4_reqsk_send_ack(struct sk_buff *rxskb,
-				   struct request_sock *req)
-{
-	int err;
-	struct dccp_hdr *rxdh =3D dccp_hdr(rxskb), *dh;
-	const u32 dccp_hdr_ack_len =3D sizeof(struct dccp_hdr) +
-				     sizeof(struct dccp_hdr_ext) +
-				     sizeof(struct dccp_hdr_ack_bits);
-	struct sk_buff *skb;
-
-	if (((struct rtable *)rxskb->dst)->rt_type !=3D RTN_LOCAL)
-		return;
-
-	skb =3D alloc_skb(dccp_v4_ctl_socket->sk->sk_prot->max_header, GFP_ATOMIC=
);
-	if (skb =3D NULL)
-		return;
-
-	/* Reserve space for headers. */
-	skb_reserve(skb, dccp_v4_ctl_socket->sk->sk_prot->max_header);
-	skb->dst =3D dst_clone(rxskb->dst);
-
-	dh =3D dccp_zeroed_hdr(skb, dccp_hdr_ack_len);
-
-	/* Build DCCP header and checksum it. */
-	dh->dccph_type	   =3D DCCP_PKT_ACK;
-	dh->dccph_sport	   =3D rxdh->dccph_dport;
-	dh->dccph_dport	   =3D rxdh->dccph_sport;
-	dh->dccph_doff	   =3D dccp_hdr_ack_len / 4;
-	dh->dccph_x	   =3D 1;
-
-	dccp_hdr_set_seq(dh, DCCP_SKB_CB(rxskb)->dccpd_ack_seq);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
-			 DCCP_SKB_CB(rxskb)->dccpd_seq);
-
-	bh_lock_sock(dccp_v4_ctl_socket->sk);
-	err =3D ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
-				    rxskb->nh.iph->daddr,
-				    rxskb->nh.iph->saddr, NULL);
-	bh_unlock_sock(dccp_v4_ctl_socket->sk);
-
-	if (err =3D NET_XMIT_CN || err =3D 0) {
-		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
-		DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
-	}
-}
-
 static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
 				 struct dst_entry *dst)
 {
@@ -1032,7 +986,7 @@ static struct request_sock_ops dccp_requ
 	.family		=3D PF_INET,
 	.obj_size	=3D sizeof(struct dccp_request_sock),
 	.rtx_syn_ack	=3D dccp_v4_send_response,
-	.send_ack	=3D dccp_v4_reqsk_send_ack,
+	.send_ack	=3D dccp_reqsk_send_ack,
 	.destructor	=3D dccp_v4_reqsk_destructor,
 	.send_reset	=3D dccp_v4_ctl_send_reset,
 };
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 07e0b7f..07ac08d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -37,8 +37,6 @@ #include "feat.h"
 static struct socket *dccp_v6_ctl_socket;
=20
 static void dccp_v6_ctl_send_reset(struct sk_buff *skb);
-static void dccp_v6_reqsk_send_ack(struct sk_buff *skb,
-				   struct request_sock *req);
 static void dccp_v6_send_check(struct sock *sk, int len, struct sk_buff *s=
kb);
=20
 static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
@@ -493,7 +491,7 @@ static struct request_sock_ops dccp6_req
 	.family		=3D AF_INET6,
 	.obj_size	=3D sizeof(struct dccp6_request_sock),
 	.rtx_syn_ack	=3D dccp_v6_send_response,
-	.send_ack	=3D dccp_v6_reqsk_send_ack,
+	.send_ack	=3D dccp_reqsk_send_ack,
 	.destructor	=3D dccp_v6_reqsk_destructor,
 	.send_reset	=3D dccp_v6_ctl_send_reset,
 };
@@ -582,59 +580,6 @@ static void dccp_v6_ctl_send_reset(struc
 	kfree_skb(skb);
 }
=20
-static void dccp_v6_reqsk_send_ack(struct sk_buff *rxskb,
-				   struct request_sock *req)
-{
-	struct flowi fl;
-	struct dccp_hdr *rxdh =3D dccp_hdr(rxskb), *dh;
-	const u32 dccp_hdr_ack_len =3D sizeof(struct dccp_hdr) +
-				     sizeof(struct dccp_hdr_ext) +
-				     sizeof(struct dccp_hdr_ack_bits);
-	struct sk_buff *skb;
-
-	skb =3D alloc_skb(dccp_v6_ctl_socket->sk->sk_prot->max_header,
-			GFP_ATOMIC);
-	if (skb =3D NULL)
-		return;
-
-	skb_reserve(skb, dccp_v6_ctl_socket->sk->sk_prot->max_header);
-
-	dh =3D dccp_zeroed_hdr(skb, dccp_hdr_ack_len);
-
-	/* Build DCCP header and checksum it. */
-	dh->dccph_type	=3D DCCP_PKT_ACK;
-	dh->dccph_sport =3D rxdh->dccph_dport;
-	dh->dccph_dport =3D rxdh->dccph_sport;
-	dh->dccph_doff	=3D dccp_hdr_ack_len / 4;
-	dh->dccph_x	=3D 1;
-
-	dccp_hdr_set_seq(dh, DCCP_SKB_CB(rxskb)->dccpd_ack_seq);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
-			 DCCP_SKB_CB(rxskb)->dccpd_seq);
-
-	memset(&fl, 0, sizeof(fl));
-	ipv6_addr_copy(&fl.fl6_dst, &rxskb->nh.ipv6h->saddr);
-	ipv6_addr_copy(&fl.fl6_src, &rxskb->nh.ipv6h->daddr);
-
-	/* FIXME: calculate checksum, IPv4 also should... */
-
-	fl.proto =3D IPPROTO_DCCP;
-	fl.oif =3D inet6_iif(rxskb);
-	fl.fl_ip_dport =3D dh->dccph_dport;
-	fl.fl_ip_sport =3D dh->dccph_sport;
-	security_req_classify_flow(req, &fl);
-
-	if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
-		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >=3D 0) {
-			ip6_xmit(dccp_v6_ctl_socket->sk, skb, &fl, NULL, 0);
-			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
-			return;
-		}
-	}
-
-	kfree_skb(skb);
-}
-
 static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh =3D dccp_hdr(skb);
