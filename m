From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Oct 2006 10:08:57 +0000
Subject: PACKET_SIZE option and congestion control on variable-length packets
Message-Id: <200610021108.57676@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_5UOIFDnYsnGBb8N"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_5UOIFDnYsnGBb8N
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

There have been discussions on whether `s' is fixed in CCID 2/3 or whether,
in spite of RFC 4341/2, `s' is variable. To resolve the discussion into
material which is practically implementable and yet does not defy existing
standards-track documents, a simple algorithmic strategy is suggested below.

An aside to the discussion was the PACKET_SIZE socket option, but in actual
fact this option is of no use other than causing unnecessary confusion: for
CCID 2 it is entirely irrelevant, and for CCID 3 (and its variations) it is
redundant and not useful due to argumentation below.=20

Strategy
=2D---------
1/ Remove the PACKET_SIZE socket options as they don't help with the proble=
m;
    I have therefore updated Ian's patch to be used standalone [attached].
2/ In the initialisation code, set ccid3hctx_s =3D ccid3hcrx_s =3D 0  inste=
ad of the
    TFRC_STD_PACKET_SIZE (which would give wrong estimates)
3/ Update  ccid3hc{rx,tx}_s using the `payload len' value taken each time f=
rom
	* dccp_sendmsg (after the check against dccp_mss_cache)
	* dccp_v{4,6}_rcv (only on Data/DataAck packets)
    using a moving average with a large q =3D 8/10 ... 9/10:
       s  <--  q * s   +  (1-q) * len
4/ Don't use MTU minus header length for `s'  (justified below).

Thus, if the application is well-behaved and sends only `fixed' size packet=
s, step
(3) reduces to a no-op. Otherwise, it slowly converges to a long-term value=
=2E The
exact/optimal weight of q can be found through experimentation, but 9/10 se=
ems
conservative enough. The algorithm above is in accordance with recent modif=
ications
suggested in  [HFPW06]. It could be extended to guard against excessive cha=
nges in
packet length for CCID 2 as suggested in [RFC 4341, sec. 5.3].

			R A T I O N A L E

The problem in assuming that `s' may vary and in allowing it to be set to
some other (but fixed) value, such as the path MTU minus header/option
lengths, lies in required changes to the loss rate estimation algorithm.=20

References which explicitly warn against this are given below; in both=20
[Wid00, p. 21] and [FHP+00, 3.1.2] it is pointed out that this part has tak=
en
much discussion and testing; for good reasons, since any changes endanger
both efficiency and fairness wrt competing  TCP flows.=20

Theorems and numerical examples that attest that inaccuracies lead to eithe=
r=20
non-TCP-friendly or suboptimal application behaviour can be found in [RR99];
trends to be confirmed later by a much more comprehensive analysis in [VLB0=
5].

These findings were validated and confirmed by Widmer et al in [WBLB04]. Th=
is
article, as well as the earlier technical report [Vas00] warn against using=
 the MTU
as `fixed' packet size parameter of the throughput equation, in such scenar=
ios where
the application is allowed to send variable-sized packets. To solve the pro=
blem of a
non-`fixed' s,  Widmer et al introduce a number of changes to  the loss est=
imation
algorithm in [WBLB04].=20

Similar ideas and a confirmation that the loss interval estimation needs up=
dating when `s' may
vary can be found in [FK06]; where a constant of s=3D1460 is plugged into t=
he throughput equation.
Consequently adjustments  to estimating the loss event rate do follow; and =
 an upper bound on the
sending rate is additionally imposed to support using non-`fixed' s.

In summary, using variable packet sizes is not well understood and even les=
s well specified. There are
several publications which explicitly warn against clamping `s' to the path=
 MTU [Vas00,  WBLB04,VLB05,
RR99] and thereby allowing applications to be liberal with (the length of) =
what they send.=20


References
=2D-------------
[RR99]       Ramesh, Sridhar and Injong Rhee. Issues in TCP Model-Based Flow
             Control. Technical report, TR-99-15, NCSU, North Carolina State
             University, Raleigh, 1999.

[VLB05]      Vojnovic, Milan and Jean-Yves Le Boudec. On the long-run behav=
ior
             of equation-based rate control. IEEE/ACM Transactions on
             Networking (TON), 13(3):568--581, 6/2005.

[WBLB04]     Widmer, J=F6rg, Catherine Boutremans and Jean-Yves Le Boudec.
             End-to-End Congestion Control for TCP-Friendly Flows with
             Variable Packet Size. ACM SIGCOMM Computer Communication Revie=
w,
             34(2):137--151, 4/2004.

[Vas00]      Vasallo, Pedro Reviriego. Variable Packet Size Equation Based
             Congestion Control. Technical Report, tr-00-008, ICSI, 4/2000.

[FK06]       Floyd, Sally and Eddie Kohler. TCP Friendly Rate Control (TFRC=
):
             the Small-Packet (SP) Variant. draft-ietf-dccp-tfrc-voip-05.tx=
t,
             1/3/2006.

[HFPW06]  draft-floyd-rfc3448bis-00.txt

[Wid00]      Widmer, J=F6rg. Equation-Based Congestion Control. Diploma The=
sis,
             Department of Mathematics and Computer Science, University of
             Mannheim, Germany, 2/2000.

[FHP+00]     Floyd, Sally, Mark Handley, Jitendra Padhye and J=F6rg Widmer.
             Equation-Based Congestion Control for Unicast Applications. ACM
             SIGCOMM Computer Communication Review, 30(4):43--56, 10/2000.

--Boundary-00=_5UOIFDnYsnGBb8N
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="remove_PACKET_SIZE_option.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="remove_PACKET_SIZE_option.diff"

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index d6f4ec4..628035f 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -196,7 +196,6 @@ struct dccp_so_feat {
 };
 
 /* DCCP socket options */
-#define DCCP_SOCKOPT_PACKET_SIZE	1
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
@@ -464,7 +463,6 @@ struct dccp_sock {
 	struct dccp_service_list	*dccps_service_list;
 	struct timeval			dccps_timestamp_time;
 	__u32				dccps_timestamp_echo;
-	__u32				dccps_packet_size;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
 	unsigned long			dccps_ndp_count;
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index cec23ad..aa8f19e 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -652,11 +652,7 @@ static int ccid3_hc_tx_init(struct ccid 
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
-	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
-		hctx->ccid3hctx_s = dp->dccps_packet_size;
-	else
-		hctx->ccid3hctx_s = TFRC_STD_PACKET_SIZE;
+	hctx->ccid3hctx_s = TFRC_STD_PACKET_SIZE;
 
 	/* Set transmission rate to 1 packet per second */
 	hctx->ccid3hctx_x     = hctx->ccid3hctx_s;
@@ -1125,11 +1121,7 @@ static int ccid3_hc_rx_init(struct ccid 
 
 	ccid3_pr_debug("%s, sk=%p\n", dccp_role(sk), sk);
 
-	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
-	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
-		hcrx->ccid3hcrx_s = dp->dccps_packet_size;
-	else
-		hcrx->ccid3hcrx_s = TFRC_STD_PACKET_SIZE;
+	hcrx->ccid3hcrx_s = TFRC_STD_PACKET_SIZE;
 
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d3e6e81..69ba5c3 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -451,8 +451,7 @@ out_free_val:
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		char __user *optval, int optlen)
 {
-	struct dccp_sock *dp;
-	int err;
+	int err = 0;
 	int val;
 
 	if (optlen < sizeof(int))
@@ -465,14 +464,8 @@ static int do_dccp_setsockopt(struct soc
 		return dccp_setsockopt_service(sk, val, optval, optlen);
 
 	lock_sock(sk);
-	dp = dccp_sk(sk);
-	err = 0;
 
 	switch (optname) {
-	case DCCP_SOCKOPT_PACKET_SIZE:
-		dp->dccps_packet_size = val;
-		break;
-
 	case DCCP_SOCKOPT_CHANGE_L:
 		if (optlen != sizeof(struct dccp_so_feat))
 			err = -EINVAL;
@@ -568,10 +561,6 @@ static int do_dccp_getsockopt(struct soc
 	dp = dccp_sk(sk);
 
 	switch (optname) {
-	case DCCP_SOCKOPT_PACKET_SIZE:
-		val = dp->dccps_packet_size;
-		len = sizeof(dp->dccps_packet_size);
-		break;
 	case DCCP_SOCKOPT_SERVICE:
 		return dccp_getsockopt_service(sk, len,
 					       (__be32 __user *)optval, optlen);

--Boundary-00=_5UOIFDnYsnGBb8N--
