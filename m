From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:37:54 +0000
Subject: [PATCH 1/11][DCCP] ackvec: Ditch dccpav_buf_len
Message-Id: <39e6f6c70602031837ve29a7efm23d5e740f9239dcc@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11442_5668937.1139020674005"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11442_5668937.1139020674005
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11442_5668937.1139020674005
Content-Type: text/x-patch; name=1.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9b1zpz
Content-Disposition: attachment; filename="1.patch"

tree 10a90ca17347915aa5643ed1795a1312c750a440
parent 2799e0977dcf6010c469332e5639fcea179bcd9f
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138881941 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138881941 -0200

[DCCP] ackvec: Ditch dccpav_buf_len

Simplifying the code a bit as we're always using DCCP_MAX_ACKVEC_LEN.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c    |   24 ++++++++++--------------
 ackvec.h    |   10 +++-------
 ipv4.c      |    3 +--
 minisocks.c |    3 +--
 4 files changed, 15 insertions(+), 25 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 2c77daf..3483740 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -20,6 +20,10 @@
 int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+#ifdef CONFIG_IP_DCCP_DEBUG
+	const char *debug_prefix = dp->dccps_role == DCCP_ROLE_CLIENT ?
+				"CLIENT tx: " : "server tx: ";
+#endif
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
 	int len = av->dccpav_vec_len + 2;
 	struct timeval now;
@@ -90,21 +94,13 @@ int dccp_insert_option_ackvec(struct soc
 	return -1;
 }
 
-struct dccp_ackvec *dccp_ackvec_alloc(const unsigned int len,
-				      const gfp_t priority)
+struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 {
-	struct dccp_ackvec *av;
-
-	BUG_ON(len == 0);
-
-	if (len > DCCP_MAX_ACKVEC_LEN)
-		return NULL;
+	struct dccp_ackvec *av = kmalloc(sizeof(*av), priority);
 
-	av = kmalloc(sizeof(*av) + len, priority);
 	if (av != NULL) {
-		av->dccpav_buf_len	= len;
 		av->dccpav_buf_head	=
-			av->dccpav_buf_tail = av->dccpav_buf_len - 1;
+			av->dccpav_buf_tail = DCCP_MAX_ACKVEC_LEN - 1;
 		av->dccpav_buf_ackno	=
 			av->dccpav_ack_ackno = av->dccpav_ack_seqno = ~0LLU;
 		av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
@@ -146,7 +142,7 @@ static inline int dccp_ackvec_set_buf_he
 	unsigned int gap;
 	long new_head;
 
-	if (av->dccpav_vec_len + packets > av->dccpav_buf_len)
+	if (av->dccpav_vec_len + packets > DCCP_MAX_ACKVEC_LEN)
 		return -ENOBUFS;
 
 	gap	 = packets - 1;
@@ -158,7 +154,7 @@ static inline int dccp_ackvec_set_buf_he
 			       gap + new_head + 1);
 			gap = -new_head;
 		}
-		new_head += av->dccpav_buf_len;
+		new_head += DCCP_MAX_ACKVEC_LEN;
 	} 
 
 	av->dccpav_buf_head = new_head;
@@ -251,7 +247,7 @@ int dccp_ackvec_add(struct dccp_ackvec *
 				goto out_duplicate;
 
 			delta -= len + 1;
-			if (++index == av->dccpav_buf_len)
+			if (++index == DCCP_MAX_ACKVEC_LEN)
 				index = 0;
 		}
 	}
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index f7dfb5f..f083daf 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -49,7 +49,6 @@
  * 		       (HC-Sender seqno)
  * @dccpav_ack_nonce - the one-bit sum of the ECN Nonces for all State 0.
  *
- * @dccpav_buf_len	- circular buffer length
  * @dccpav_time		- the time in usecs
  * @dccpav_buf - circular buffer of acknowledgeable packets
  */
@@ -63,18 +62,16 @@ struct dccp_ackvec {
 	u8		dccpav_ack_ptr;
 	u8		dccpav_sent_len;
 	u8		dccpav_vec_len;
-	u8		dccpav_buf_len;
 	u8		dccpav_buf_nonce;
 	u8		dccpav_ack_nonce;
-	u8		dccpav_buf[0];
+	u8		dccpav_buf[DCCP_MAX_ACKVEC_LEN];
 };
 
 struct sock;
 struct sk_buff;
 
 #ifdef CONFIG_IP_DCCP_ACKVEC
-extern struct dccp_ackvec *dccp_ackvec_alloc(unsigned int len,
-					  const gfp_t priority);
+extern struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority);
 extern void dccp_ackvec_free(struct dccp_ackvec *av);
 
 extern int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
@@ -92,8 +89,7 @@ static inline int dccp_ackvec_pending(co
 	return av->dccpav_sent_len != av->dccpav_vec_len;
 }
 #else /* CONFIG_IP_DCCP_ACKVEC */
-static inline struct dccp_ackvec *dccp_ackvec_alloc(unsigned int len,
-					   const gfp_t priority)
+static inline struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 {
 	return NULL;
 }
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 00f9832..9fedeca 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1041,8 +1041,7 @@ int dccp_v4_init_sock(struct sock *sk)
 	do_gettimeofday(&dp->dccps_epoch);
 
 	if (dp->dccps_options.dccpo_send_ack_vector) {
-		dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(DCCP_MAX_ACKVEC_LEN,
-							   GFP_KERNEL);
+		dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
 		if (dp->dccps_hc_rx_ackvec == NULL)
 			return -ENOMEM;
 	}
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 29261fc..a60a3e9 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -116,8 +116,7 @@ struct sock *dccp_create_openreq_child(s
 
 		if (newdp->dccps_options.dccpo_send_ack_vector) {
 			newdp->dccps_hc_rx_ackvec =
-				dccp_ackvec_alloc(DCCP_MAX_ACKVEC_LEN,
-						  GFP_ATOMIC);
+						dccp_ackvec_alloc(GFP_ATOMIC);
 			/*
 			 * XXX: We're using the same CCIDs set on the parent,
 			 * i.e. sk_clone copied the master sock and left the


------=_Part_11442_5668937.1139020674005--
