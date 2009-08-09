From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:39 +0000
Subject: dccp-test-tree [PATCH 2/10] Add sysctl to toggle the local support for ECN
Message-Id: <1249847327-6792-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This sysctl disables local ECN support for interpreting ECN bits.

When set to 0, the host behaves as if it were ECN-incapable: ECN bits are
ignored and the mandatory "Change L(ECN Incapable, 1)" (RFC 4340, 12.1) is
sent during feature negotiation to signal to the other endpoint to signal
that ECN bits will not be interpreted.

The behaviour is slightly different from the tcp_ecn sysctl, since DCCP
connections are ECN-enabled per default.

Setting ECT codepoints in outgoing packets can not be controlled by this sysctl,
but is possible by setting the sysctl to 0 at the remote (receiving) end. This
signals that the remote end can not read ECN bits. Due to RFC 4340, 12.2, all
outgoing packets are then sent as ECN-incapable.

Inter-operability issues: the host does not set a preference for the remote ECN
Incapable feature. Within the existing feature-negotiation infrastructure, this
ensures that all valid values (ECN Incapable = 0 or 1) are acceptable.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   12 ++++++++++++
 net/dccp/feat.c                   |   23 ++++++++++++++++-------
 net/dccp/feat.h                   |    1 +
 net/dccp/sysctl.c                 |    8 ++++++++
 4 files changed, 37 insertions(+), 7 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -29,6 +29,12 @@ It has a base protocol and pluggable congestion control IDs (CCIDs).
 DCCP is a Proposed Standard (RFC 2026), and the homepage for DCCP as a protocol
 is at http://www.ietf.org/html.charters/dccp-charter.html
 
+ECN Support
+=====+By default, all outgoing packets are sent with ECT(0) as per RFC 3168, sec. 5.
+This can be disabled by setting the `ecn_local' sysctl to 0 (see below). The
+ECN Nonce (RFC 3540) is not supported.
+
 Missing features
 ========
 
@@ -163,6 +169,12 @@ seq_window = 100
 	The initial sequence window (sec. 7.5.2) of the sender. This influences
 	the local ackno validity and the remote seqno validity windows (7.5.1).
 
+ecn_local = 1
+	This toggles local ECN support: when set to 0, ECN Incapable (sec. 12.1)
+	is sent and ECN bits of incoming packets are ignored. Note that this is
+	different from tcp_ecn: to disable sending of ECT codepoints, the remote
+	peer needs to set this sysctl to zero.
+
 tx_qlen = 5
 	The size of the transmit buffer in packets. A value of 0 corresponds
 	to an unbounded transmit buffer.
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -29,7 +29,8 @@
 /* feature-specific sysctls - initialised to the defaults from RFC 4340, 6.4 */
 unsigned long	sysctl_dccp_sequence_window __read_mostly = 100;
 int		sysctl_dccp_rx_ccid	    __read_mostly = 2,
-		sysctl_dccp_tx_ccid	    __read_mostly = 2;
+		sysctl_dccp_tx_ccid	    __read_mostly = 2,
+		sysctl_dccp_ecn_local	    __read_mostly = true;
 
 /*
  * Feature activation handlers.
@@ -1111,7 +1112,8 @@ static u8 dccp_feat_change_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
 		 * No particular preferences have been registered. We deal with
 		 * this situation by assuming that all valid values are equally
 		 * acceptable, and apply the following checks:
-		 * - if the peer's list is a singleton, we accept a valid value;
+		 * - if the peer's list is a singleton, we accept a valid value
+		 *   (allows to cope gracefully with e.g. remote ECN Incapable);
 		 * - if we are the server, we first try to see if the peer (the
 		 *   client) advertises the default value. If yes, we use it,
 		 *   otherwise we accept the preferred value;
@@ -1430,11 +1432,18 @@ int dccp_feat_init(struct sock *sk)
 	rc = __feat_register_sp(fn, DCCPF_SHORT_SEQNOS, true, true, &off, 1);
 	if (rc)
 		return rc;
-
-	/* RFC 4340 12.1: "If a DCCP is not ECN capable, ..." */
-	rc = __feat_register_sp(fn, DCCPF_ECN_INCAPABLE, true, true, &on, 1);
-	if (rc)
-		return rc;
+	/*
+	 * ECN Incapable Feature (RFC 4340, 12.1)
+	 *
+	 * We do not register preferences for the feature-remote value, so that
+	 * the preference list is empty and either value is locally acceptable.
+	 */
+	if (!sysctl_dccp_ecn_local) {
+		rc = __feat_register_sp(fn, DCCPF_ECN_INCAPABLE,
+					    true, true, &on, 1);
+		if (rc)
+			return rc;
+	}
 
 	/*
 	 * We advertise the available list of CCIDs and reorder according to
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -106,6 +106,7 @@ struct ccid_dependency {
 extern unsigned long sysctl_dccp_sequence_window;
 extern int	     sysctl_dccp_rx_ccid;
 extern int	     sysctl_dccp_tx_ccid;
+extern int	     sysctl_dccp_ecn_local;
 
 extern int  dccp_feat_init(struct sock *sk);
 extern void dccp_feat_initialise_sysctls(void);
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -78,6 +78,14 @@ static struct ctl_table dccp_default_table[] = {
 		.extra2		= &u8_max,
 	},
 	{
+		.procname	= "ecn_local",
+		.data		= &sysctl_dccp_ecn_local,
+		.maxlen		= sizeof(sysctl_dccp_ecn_local),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
 		.procname	= "tx_qlen",
 		.data		= &sysctl_dccp_tx_qlen,
 		.maxlen		= sizeof(sysctl_dccp_tx_qlen),
-- 
1.6.0.rc2

