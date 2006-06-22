From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 22 Jun 2006 03:42:17 +0000
Subject: [PATCH 1/1] [DCCP]: Fix default sequence window size
Message-Id: <449A1199.1080404@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When using the default sequence window size (100) I got the following in 
my logs:
Jun 22 14:24:09 localhost kernel: [ 1492.114775] DCCP: Step 6 failed for 
DATA packet, (LSWL(6279674225) <= P.seqno(6279674749) <= 
S.SWH(6279674324)) and (P.ackno doesn't exist or LAWL(18798206530) <= 
P.ackno(1125899906842620) <= S.AWH(18798206548), sending SYNC...
Jun 22 14:24:09 localhost kernel: [ 1492.115147] DCCP: Step 6 failed for 
DATA packet, (LSWL(6279674225) <= P.seqno(6279674750) <= 
S.SWH(6279674324)) and (P.ackno doesn't exist or LAWL(18798206530) <= 
P.ackno(1125899906842620) <= S.AWH(18798206549), sending SYNC...

I went to alter the default sysctl and it didn't take for new sockets. 
Below patch fixes this.

I think the default is too low but it is what the DCCP spec specifies.

As a side effect of this my rx speed using iperf goes from about 2.8 
Mbits/sec to 3.5. This is still far too slow but it is a step in the 
right direction.

Compile tested only for IPv6 but not particularly complex change.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

---

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f2c011f..3119804 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -32,6 +32,8 @@ #include "ccid.h"
  #include "dccp.h"
  #include "feat.h"

+extern int dccp_feat_default_sequence_window;
+
  /*
   * This is the global socket data structure used for responding to
   * the Out-of-the-blue (OOTB) packets. A control sock will be created
@@ -505,8 +507,7 @@ int dccp_v4_conn_request(struct sock *sk
  	ireq = inet_rsk(req);
  	ireq->loc_addr = daddr;
  	ireq->rmt_addr = saddr;
-	req->rcv_wnd	= 100; /* Fake, option parsing will get the
-				  right value */
+	req->rcv_wnd	= dccp_feat_default_sequence_window;
  	ireq->opt	= NULL;

  	/*
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 65e2ab0..aa147f4 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -33,6 +33,8 @@ #include <net/xfrm.h>
  #include "dccp.h"
  #include "ipv6.h"

+extern int dccp_feat_default_sequence_window;
+
  /* Socket used for sending RSTs and ACKs */
  static struct socket *dccp_v6_ctl_socket;

@@ -708,8 +710,7 @@ static int dccp_v6_conn_request(struct s
  	ireq = inet_rsk(req);
  	ipv6_addr_copy(&ireq6->rmt_addr, &skb->nh.ipv6h->saddr);
  	ipv6_addr_copy(&ireq6->loc_addr, &skb->nh.ipv6h->daddr);
-	req->rcv_wnd	= 100; /* Fake, option parsing will get the
-				  right value */
+	req->rcv_wnd	= dccp_feat_default_sequence_window;
  	ireq6->pktopts	= NULL;

  	if (ipv6_opt_accepted(sk, skb) ||
diff --git a/net/dccp/options.c b/net/dccp/options.c
index e9feb2a..6409561 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -30,6 +30,8 @@ int dccp_feat_default_ack_ratio	        int dccp_feat_default_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
  int dccp_feat_default_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;

+EXPORT_SYMBOL_GPL(dccp_feat_default_sequence_window);
+
  void dccp_minisock_init(struct dccp_minisock *dmsk)
  {
  	dmsk->dccpms_sequence_window = dccp_feat_default_sequence_window;

