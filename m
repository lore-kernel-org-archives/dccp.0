From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 04 Jan 2006 04:12:59 +0000
Subject: [PATCH 2/4][DCCP] ackvec: use u8 for the buf offsets
Message-Id: <39e6f6c70601032012p12427663qbb4dc124429e6fbe@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_37833_5580085.1136347979245"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_37833_5580085.1136347979245
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

 Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.git

Best Regards,

- Arnaldo

------=_Part_37833_5580085.1136347979245
Content-Type: text/x-patch; name=2.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="2.patch"

tree cf5ca5bb82cc5e7ef01a368bf6b86029266bc146
parent 6742bbcbb8a0959e1dff0ce055768e3217d9967a
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1136346394 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1136346394 -0200

[DCCP] ackvec: use u8 for the buf offsets

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c |   27 +++++++++++++++++----------
 ackvec.h |   12 ++++++------
 2 files changed, 23 insertions(+), 16 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index a979f4e..ce9cb77 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -55,8 +55,8 @@ int dccp_insert_option_ackvec(struct soc
 	from = av->dccpav_buf + av->dccpav_buf_head;
 
 	/* Check if buf_head wraps */
-	if (av->dccpav_buf_head + len > av->dccpav_vec_len) {
-		const u32 tailsize = (av->dccpav_vec_len - av->dccpav_buf_head);
+	if ((int)av->dccpav_buf_head + len > av->dccpav_vec_len) {
+		const u32 tailsize = av->dccpav_vec_len - av->dccpav_buf_head;
 
 		memcpy(to, from, tailsize);
 		to   += tailsize;
@@ -93,8 +93,14 @@ int dccp_insert_option_ackvec(struct soc
 struct dccp_ackvec *dccp_ackvec_alloc(const unsigned int len,
 				      const gfp_t priority)
 {
-	struct dccp_ackvec *av = kmalloc(sizeof(*av) + len, priority);
+	struct dccp_ackvec *av;
 
+	BUG_ON(len == 0);
+
+	if (len > DCCP_MAX_ACKVEC_LEN)
+		return NULL;
+
+	av = kmalloc(sizeof(*av) + len, priority);
 	if (av != NULL) {
 		av->dccpav_buf_len	= len;
 		av->dccpav_buf_head	=
@@ -117,13 +123,13 @@ void dccp_ackvec_free(struct dccp_ackvec
 }
 
 static inline u8 dccp_ackvec_state(const struct dccp_ackvec *av,
-				   const unsigned int index)
+				   const u8 index)
 {
 	return av->dccpav_buf[index] & DCCP_ACKVEC_STATE_MASK;
 }
 
 static inline u8 dccp_ackvec_len(const struct dccp_ackvec *av,
-				 const unsigned int index)
+				 const u8 index)
 {
 	return av->dccpav_buf[index] & DCCP_ACKVEC_LEN_MASK;
 }
@@ -135,7 +141,7 @@ static inline u8 dccp_ackvec_len(const s
  */
 static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 						 const unsigned int packets,
-						  const unsigned char state)
+						 const unsigned char state)
 {
 	unsigned int gap;
 	signed long new_head;
@@ -223,7 +229,7 @@ int dccp_ackvec_add(struct dccp_ackvec *
 		 *	could reduce the complexity of this scan.)
 		 */
 		u64 delta = dccp_delta_seqno(ackno, av->dccpav_buf_ackno);
-		unsigned int index = av->dccpav_buf_head;
+		u8 index = av->dccpav_buf_head;
 
 		while (1) {
 			const u8 len = dccp_ackvec_len(av, index);
@@ -301,9 +307,10 @@ static void dccp_ackvec_throw_away_ack_r
 	 * draft-ietf-dccp-spec-11.txt Appendix A. -acme
 	 */
 #if 0
-	av->dccpav_buf_tail = av->dccpav_ack_ptr + 1;
-	if (av->dccpav_buf_tail >= av->dccpav_vec_len)
-		av->dccpav_buf_tail -= av->dccpav_vec_len;
+	u32 new_buf_tail = av->dccpav_ack_ptr + 1;
+	if (new_buf_tail >= av->dccpav_vec_len)
+		new_buf_tail -= av->dccpav_vec_len;
+	av->dccpav_buf_tail = new_buf_tail;
 #endif
 	av->dccpav_vec_len -= av->dccpav_sent_len;
 }
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index d0fd6c6..f7dfb5f 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -54,16 +54,16 @@
  * @dccpav_buf - circular buffer of acknowledgeable packets
  */
 struct dccp_ackvec {
-	unsigned int	dccpav_buf_head;
-	unsigned int	dccpav_buf_tail;
 	u64		dccpav_buf_ackno;
 	u64		dccpav_ack_seqno;
 	u64		dccpav_ack_ackno;
-	unsigned int	dccpav_ack_ptr;
-	unsigned int	dccpav_sent_len;
-	unsigned int	dccpav_vec_len;
-	unsigned int	dccpav_buf_len;
 	struct timeval	dccpav_time;
+	u8		dccpav_buf_head;
+	u8		dccpav_buf_tail;
+	u8		dccpav_ack_ptr;
+	u8		dccpav_sent_len;
+	u8		dccpav_vec_len;
+	u8		dccpav_buf_len;
 	u8		dccpav_buf_nonce;
 	u8		dccpav_ack_nonce;
 	u8		dccpav_buf[0];


------=_Part_37833_5580085.1136347979245--
