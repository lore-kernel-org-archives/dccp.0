From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:44:44 +0000
Subject: [PATCH 09/37] dccp: Resolve dependencies of features on choice of CCID
Message-Id: <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This provides a missing link in the code chain, as several features implicitly
depend and/or rely on the choice of CCID. Most notably, this is the Send Ack Vector
feature, but also Ack Ratio and Send Loss Event Rate (also taken care of).

For Send Ack Vector, the situation is as follows:
 * since CCID2 mandates the use of Ack Vectors, there is no point in allowing
   endpoints which use CCID2 to disable Ack Vector features such a connection;

 * a peer with a TX CCID of CCID2 will always expect Ack Vectors, and a peer
   with a RX CCID of CCID2 must always send Ack Vectors (RFC 4341, sec. 4);

 * for all other CCIDs, the use of (Send) Ack Vector is optional and thus
   negotiable. However, this implies that the code negotiating the use of Ack
   Vectors also supports it (i.e. is able to supply and to either parse or
   ignore received Ack Vectors). Since this is not the case (CCID-3 has no Ack
   Vector support), the use of Ack Vectors is here disabled, with a comment
   in the source code.

An analogous consideration arises for the Send Loss Event Rate feature,
since the CCID-3 implementation does not support the loss interval options
of RFC 4342. To make such use explicit, corresponding feature-negotiation
options are inserted which signal the use of the loss event rate option,
as it is used by the CCID3 code.

Lastly, the values of the Ack Ratio feature are matched to the choice of CCID.

The patch implements this as a function which is called after the user has
made all other registrations for changing default values of features.

The table is variable-length, the reserved (and hence for feature-negotiation
invalid, confirmed by considering section 19.4 of RFC 4340) feature number `0'
is used to mark the end of the table.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h   |    1 +
 net/dccp/feat.c   |  160 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/output.c |    4 +
 net/dccp/proto.c  |    3 +
 4 files changed, 168 insertions(+), 0 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -442,6 +442,7 @@ static inline int dccp_ack_pending(const struct sock *sk)
 	       inet_csk_ack_scheduled(sk);
 }
 
+extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
 extern void dccp_feat_list_purge(struct list_head *fn_list);
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -438,6 +438,166 @@ int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
 
 EXPORT_SYMBOL_GPL(dccp_feat_change);
 
+/*
+ *	Tracking features whose value depend on the choice of CCID
+ *
+ * This is designed with an extension in mind so that a list walk could be done
+ * before activating any features. However, the existing framework was found to
+ * work satisfactorily up until now, the automatic verification is left open.
+ * When adding new CCIDs, add a corresponding dependency table here.
+ */
+static const struct ccid_dependency *dccp_feat_ccid_deps(u8 ccid, bool is_local)
+{
+	static const struct ccid_dependency ccid2_dependencies[2][2] = {
+		/*
+		 * CCID2 mandates Ack Vectors (RFC 4341, 4.): as CCID is a TX
+		 * feature and Send Ack Vector is an RX feature, `is_local'
+		 * needs to be reversed.
+		 */
+		{	/* Dependencies of the receiver-side (remote) CCID2 */
+			{
+				.dependent_feat	= DCCPF_SEND_ACK_VECTOR,
+				.is_local	= true,
+				.is_mandatory	= true,
+				.val		= 1
+			},
+			{ 0, 0, 0, 0 }
+		},
+		{	/* Dependencies of the sender-side (local) CCID2 */
+			{
+				.dependent_feat	= DCCPF_SEND_ACK_VECTOR,
+				.is_local	= false,
+				.is_mandatory	= true,
+				.val		= 1
+			},
+			{ 0, 0, 0, 0 }
+		}
+	};
+	static const struct ccid_dependency ccid3_dependencies[2][5] = {
+		{	/*
+			 * Dependencies of the receiver-side CCID3
+			 */
+			{	/* locally disable Ack Vectors */
+				.dependent_feat	= DCCPF_SEND_ACK_VECTOR,
+				.is_local	= true,
+				.is_mandatory	= false,
+				.val		= 0
+			},
+			{	/* see below why Send Loss Event Rate is on */
+				.dependent_feat	= DCCPF_SEND_LEV_RATE,
+				.is_local	= true,
+				.is_mandatory	= true,
+				.val		= 1
+			},
+			{	/* NDP Count is needed as per RFC 4342, 6.1.1 */
+				.dependent_feat	= DCCPF_SEND_NDP_COUNT,
+				.is_local	= false,
+				.is_mandatory	= true,
+				.val		= 1
+			},
+			{ 0, 0, 0, 0 },
+		},
+		{	/*
+			 * CCID3 at the TX side: we request that the HC-receiver
+			 * will not send Ack Vectors (they will be ignored, so
+			 * Mandatory is not set); we enable Send Loss Event Rate
+			 * (Mandatory since the implementation does not support
+			 * the Loss Intervals option of RFC 4342, 8.6).
+			 * The last two options are for peer's information only.
+			*/
+			{
+				.dependent_feat	= DCCPF_SEND_ACK_VECTOR,
+				.is_local	= false,
+				.is_mandatory	= false,
+				.val		= 0
+			},
+			{
+				.dependent_feat	= DCCPF_SEND_LEV_RATE,
+				.is_local	= false,
+				.is_mandatory	= true,
+				.val		= 1
+			},
+			{	/* this CCID does not support Ack Ratio */
+				.dependent_feat	= DCCPF_ACK_RATIO,
+				.is_local	= true,
+				.is_mandatory	= false,
+				.val		= 0
+			},
+			{	/* tell receiver we are sending NDP counts */
+				.dependent_feat	= DCCPF_SEND_NDP_COUNT,
+				.is_local	= true,
+				.is_mandatory	= false,
+				.val		= 1
+			},
+			{ 0, 0, 0, 0 }
+		}
+	};
+	switch (ccid) {
+	case DCCPC_CCID2:
+		return ccid2_dependencies[is_local];
+	case DCCPC_CCID3:
+		return ccid3_dependencies[is_local];
+	default:
+		return NULL;
+	}
+}
+
+/**
+ * dccp_feat_propagate_ccid - Resolve dependencies of features on choice of CCID
+ * @fn: feature-negotiation list to update
+ * @id: CCID number to track
+ * @is_local: whether TX CCID (1) or RX CCID (0) is meant
+ * This function needs to be called after registering all other features.
+ */
+static int dccp_feat_propagate_ccid(struct list_head *fn, u8 id, bool is_local)
+{
+	const struct ccid_dependency *table = dccp_feat_ccid_deps(id, is_local);
+	int i, rc = (table = NULL);
+
+	for (i = 0; rc = 0 && table[i].dependent_feat != DCCPF_RESERVED; i++)
+		if (dccp_feat_type(table[i].dependent_feat) = FEAT_SP)
+			rc = __feat_register_sp(fn, table[i].dependent_feat,
+						    table[i].is_local,
+						    table[i].is_mandatory,
+						    &table[i].val, 1);
+		else
+			rc = __feat_register_nn(fn, table[i].dependent_feat,
+						    table[i].is_mandatory,
+						    table[i].val);
+	return rc;
+}
+
+/**
+ * dccp_feat_finalise_settings  -  Finalise settings before starting negotiation
+ * @dp: client or listening socket (settings will be inherited)
+ * This is called after all registrations (socket initialisation, sysctls, and
+ * sockopt calls), and before sending the first packet containing Change options
+ * (ie. client-Request or server-Response), to ensure internal consistency.
+ */
+int dccp_feat_finalise_settings(struct dccp_sock *dp)
+{
+	struct list_head *fn = &dp->dccps_featneg;
+	struct dccp_feat_entry *entry;
+	int i = 2, ccids[2] = { -1, -1 };
+
+	/*
+	 * Propagating CCIDs:
+	 * 1) not useful to propagate CCID settings if this host advertises more
+	 *    than one CCID: the choice of CCID  may still change - if this is
+	 *    the client, or if this is the server and the client sends
+	 *    singleton CCID values.
+	 * 2) since is that propagate_ccid changes the list, we defer changing
+	 *    the sorted list until after the traversal.
+	 */
+	list_for_each_entry(entry, fn, node)
+		if (entry->feat_num = DCCPF_CCID && entry->val.sp.len = 1)
+			ccids[entry->is_local] = entry->val.sp.vec[0];
+	while (i--)
+		if (ccids[i] > 0 && dccp_feat_propagate_ccid(fn, ccids[i], i))
+			return -1;
+	return 0;
+}
+
 static int dccp_feat_update_ccid(struct sock *sk, u8 type, u8 new_ccid_nr)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -469,6 +469,10 @@ int dccp_connect(struct sock *sk)
 	struct sk_buff *skb;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
+	/* do not connect if feature negotiation setup fails */
+	if (dccp_feat_finalise_settings(dccp_sk(sk)))
+		return -EPROTO;
+
 	dccp_connect_init(sk);
 
 	skb = alloc_skb(sk->sk_prot->max_header, sk->sk_allocation);
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -278,6 +278,9 @@ static inline int dccp_listen_start(struct sock *sk, int backlog)
 	struct dccp_sock *dp = dccp_sk(sk);
 
 	dp->dccps_role = DCCP_ROLE_LISTEN;
+	/* do not start to listen if feature negotiation setup fails */
+	if (dccp_feat_finalise_settings(dp))
+		return -EPROTO;
 	return inet_csk_listen_start(sk, backlog);
 }
 
-- 
1.6.0.rc2

