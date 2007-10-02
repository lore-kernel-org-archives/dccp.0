From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 12:06:55 +0000
Subject: [PATCH v2 4/9]: Resolve dependencies of features on choice of CCID
Message-Id: <200710021306.55993@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Reworked patch thanks to suggestions by Ian. Changes:
 * removed on/off constants
 * used reserved feature number instead of reserved pointer value (NULL) 
   to mark the end of table; marked this in the commit message
 * all boolean types are now initialised with `true'/`false', while the
   actual feature-negotiation value (not a boolean) is used for initialisation
 * compile-tested and checked against old patch

------------------------------> Patch v2 <-----------------------------------------
[DCCP]: Resolve dependencies of features on choice of CCID

This provides a missing link in the code chain, as several features implicitly
depend and/or rely on the choice of CCID. Most notably, this is the Send Ack Vector
feature, but the patch also takes care of Ack Ratio and Send Loss Event Rate.

For Send Ack Vector, the situation is as follows:
 * since CCID2 mandates the use of Ack Vectors, there is no point in allowing endpoints
   which use CCID2 to disable Send Ack Vector features on the corresponding half-connection;

 * a peer with a TX CCID of CCID2 will always expect Ack Vectors, and a peer with a RX CCID
   of CCID2 must always send Ack Vectors (RFC 4341, sec. 4);

 * for all other CCIDs, the use of (Send) Ack Vector is optional and thus negotiable. However,
   this implies that the code negotiating the use of Ack Vectors also supports it (i.e. is
   able to supply and to either parse or ignore received Ack Vectors). Since this is not the
   case (CCID3 has no Ack Vector support), the use of Ack Vectors is here disabled, with a 
   corresponding comment in the source code.

An analogous consideration arises for the Send Loss Event Rate feature, since the CCID3 
implementation does not support the loss interval options of RFC 4342. To make such use explicit,
corresponding feature-negotiation options are inserted which signal the use of the loss event 
rate option, as it is used by the CCID3 code.

Lastly, the values of the Ack Ratio feature are matched to the choice of CCID.

The patch implements this as a function which is called after the user has made all other
registrations for changing default values of features. 

The table is variable-length, the reserved (and hence for feature-negotiation invalid, confirmed
by considering section 19.4 of RFC 4340) feature number of 0 is used to mark the end of the table.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h   |    1 
 net/dccp/feat.c   |  115 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/feat.h   |   14 ++++++
 net/dccp/output.c |    4 +
 net/dccp/proto.c  |    3 +
 5 files changed, 137 insertions(+)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -74,6 +74,20 @@ static inline u8 dccp_feat_genopt(struct
 	return entry->is_local ? DCCPO_CHANGE_L : DCCPO_CHANGE_R;
 }
 
+/**
+ * ccid_dependency  -  Record and track changes resulting from changing the CCID
+ * @feat_num: one of %dccp_feature_numbers
+ * @is_local: local (1) or remote (0) feature
+ * @is_mandatory: whether presence of @val is critical or not
+ * @val: corresponding default value for @feat_num (u8 is sufficient here)
+ */
+typedef const struct {
+	u8	feat_num;
+	bool	is_local:1,
+		is_mandatory:1;
+	u8	val;
+} ccid_dependency;
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern const char *dccp_feat_typename(const u8 type);
 extern const char *dccp_feat_name(const u8 feat);
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -422,6 +422,7 @@ static inline int dccp_ack_pending(const
 	       inet_csk_ack_scheduled(sk);
 }
 
+extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
 extern void dccp_feat_list_purge(struct list_head *fn_list);
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -432,6 +432,121 @@ int dccp_feat_change(struct dccp_minisoc
 
 EXPORT_SYMBOL_GPL(dccp_feat_change);
 
+/*
+ *	Tracking features whose value depend on the choice of CCID
+ *
+ * This is designed with an extension in mind so that a list walk could be done
+ * before activating any features. However, the existing framework was found to
+ * work satisfactorily up until now, the automatic verification is left open.
+ */
+static ccid_dependency *dccp_feat_ccid_dependency(u8 ccid, bool is_local)
+{
+	static ccid_dependency ccid2_dependencies[2][2] = {
+		/*
+		 * CCID2 mandates Ack Vectors (RFC 4341, 4.): since CCID is a TX
+		 * feature and Send Ack Vector is an RX feature, `is_local'
+		 * needs to be reversed.
+		 */
+		{	/* !is_local: dependencies of the remote (RX) CCID */
+			{ DCCPF_SEND_ACK_VECTOR, true,  true, 1 },
+			{ 0, 0, 0, 0 }
+		},
+		{	/* is_local: choices for the local (TX) CCID */
+			{ DCCPF_SEND_ACK_VECTOR, false, true, 1 },
+			{ 0, 0, 0, 0 }
+		}
+	};
+	static ccid_dependency ccid3_dependencies[2][5] = {
+		/*
+		 * CCID3 at the RX side: we locally disable Ack Vectors; enable
+		 * Send Loss Event Rate (for reasons below); and we  request NDP
+		 * options (which are used/needed as per RFC 4342, 6.1.1).
+		 */
+		{
+			{ DCCPF_SEND_ACK_VECTOR, true,  false, 0 },
+			{ DCCPF_SEND_LEV_RATE,	 true,  true,  1 },
+			{ DCCPF_SEND_NDP_COUNT,	 false, true,  1 },
+			{ 0, 0, 0, 0 },
+		}, {
+		/*
+		 * CCID3 at the TX side: we request that the HC-receiver will
+		 * not send Ack Vectors (they will be ignored, so `Mandatory' is
+		 * not set); we set Send Loss Event Rate to 1 (Mandatory since
+		 * the implementation does not support the Loss Intervals option
+		 * of RFC 4342, 8.6). The last two options are for information
+		 * only (not mandatory): this CCID does not support Ack Ratio,
+		 * but NDP Count options will be sent.
+		 */
+			{ DCCPF_SEND_ACK_VECTOR, false, false, 0 },
+			{ DCCPF_SEND_LEV_RATE,	 false, true,  1 },
+			{ DCCPF_ACK_RATIO,	 true,  false, 0 },
+			{ DCCPF_SEND_NDP_COUNT,	 true,  false, 1 },
+			{ 0, 0, 0, 0 }
+		}
+	};
+	switch (ccid) {
+	case DCCPC_CCID2: return ccid2_dependencies[is_local];
+	case DCCPC_CCID3: return ccid3_dependencies[is_local];
+	default:	  return NULL;	/* other CCIDs: no specifics yet */
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
+	ccid_dependency *table = dccp_feat_ccid_dependency(id, is_local);
+	u8 i, rc = (table = NULL);
+
+	for (i = 0; rc = 0 && table[i].feat_num != DCCPF_RESERVED; i++)
+		if (dccp_feat_type(table[i].feat_num) = FEAT_SP)
+			rc = dccp_feat_register_sp(fn, table[i].feat_num,
+						       table[i].is_local,
+						       table[i].is_mandatory,
+						      &table[i].val, 1);
+		else
+			rc = dccp_feat_register_nn(fn, table[i].feat_num,
+						       table[i].is_mandatory,
+						       table[i].val);
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
@@ -445,6 +445,10 @@ int dccp_connect(struct sock *sk)
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
@@ -282,6 +282,9 @@ static inline int dccp_listen_start(stru
 	struct dccp_sock *dp = dccp_sk(sk);
 
 	dp->dccps_role = DCCP_ROLE_LISTEN;
+	/* do not start to listen if feature negotiation setup fails */
+	if (dccp_feat_finalise_settings(dp))
+		return -EPROTO;
 	return inet_csk_listen_start(sk, backlog);
 }
 
