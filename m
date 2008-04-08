From: Patrick McHardy <kaber@trash.net>
Date: Tue, 08 Apr 2008 11:18:20 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <47FB547C.4050507@trash.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020307000307030705080106"
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--------------020307000307030705080106
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Gerrit Renker wrote:
>>
>>    - timewait transition -- question: is it possible to re-incarnate a 
>> new connection
>>      here instead of ignoring the (new) Request?
> 
> Yes, I'll change this. The tricker case is a reincarnation in the
> reverse direction. The conntrack entry must be killed and recreated
> since the state table is directional and the client/server roles
> change. Also needs a bit more thought.


The last patch handled reincarnations in the original direction,
this one adds support for reopening a connection in the reverse
direction. I used role reversal instead of recreating the conntrack
entry since that should make it easier to add DCCP_LISTEN support
later on.

(Patch might not apply because of minor cleanups I made locally,
I'll push out a new tree later).

--------------020307000307030705080106
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/linux/netfilter/nf_conntrack_dccp.h b/include/linux/netfilter/nf_conntrack_dccp.h
index 33e57c8..f3b9ce8 100644
--- a/include/linux/netfilter/nf_conntrack_dccp.h
+++ b/include/linux/netfilter/nf_conntrack_dccp.h
@@ -15,12 +15,21 @@ enum ct_dccp_states {
 	CT_DCCP_INVALID,
 	__CT_DCCP_MAX
 };
-#define CT_DCCP_MAX	(__CT_DCCP_MAX - 1)
+#define CT_DCCP_MAX		(__CT_DCCP_MAX - 1)
+
+enum ct_dccp_roles {
+	CT_DCCP_ROLE_CLIENT,
+	CT_DCCP_ROLE_SERVER,
+	__CT_DCCP_ROLE_MAX
+};
+#define CT_DCCP_ROLE_MAX	(__CT_DCCP_ROLE_MAX - 1)
 
 #ifdef __KERNEL__
+#include <net/netfilter/nf_conntrack_tuple.h>
 
 struct nf_ct_dccp {
 	u_int8_t	state;
+	u_int8_t	role[IP_CT_DIR_MAX];
 	u_int64_t	handshake_seq;
 };
 
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index bad3c6a..f768936 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -138,8 +138,8 @@ static const char * const dccp_state_names[] = {
  * or a DCCP_RESPONSE.
  */
 static const u_int8_t
-dccp_state_table[IP_CT_DIR_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
-	[IP_CT_DIR_ORIGINAL] = {
+dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
+	[CT_DCCP_ROLE_CLIENT] = {
 		[DCCP_PKT_REQUEST] = {
 		/*
 		 * sNO -> sRQ		Regular Request
@@ -157,7 +157,7 @@ dccp_state_table[IP_CT_DIR_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
 		},
 		[DCCP_PKT_RESPONSE] = {
 		/*
-		 * A Response in the original direction is always invalid.
+		 * A Response from the client is always invalid.
 		 *
 		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
 			sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV,
@@ -254,13 +254,23 @@ dccp_state_table[IP_CT_DIR_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
 			sIG, sIG, sIG, sIG, sIG, sIG, sIG, sIG,
 		},
 	},
-	[IP_CT_DIR_REPLY] = {
+	[CT_DCCP_ROLE_SERVER] = {
 		[DCCP_PKT_REQUEST] = {
 		/*
-		 * A Request in the reply direction is always invalid.
+		 * A Request from the server is only valid for reopening a
+		 * connection in TIMEWAIT state.
+		 *
+		 * sNO -> sIV
+		 * sRQ -> sIV
+		 * sRS -> sIV
+		 * sPO -> sIV
+		 * sOP -> sIV
+		 * sCR -> sIV
+		 * sCG -> sIV
+		 * sTW -> sRQ		Reincarnation, must reverse roles
 		 *
 		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
-			sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV
+			sIV, sIV, sIV, sIV, sIV, sIV, sIV, sRQ
 		},
 		[DCCP_PKT_RESPONSE] = {
 		/*
@@ -410,7 +420,7 @@ static int dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	dh = skb_header_pointer(skb, dataoff, sizeof(_dh), &dh);
 	BUG_ON(dh == NULL);
 
-	state = dccp_state_table[IP_CT_DIR_ORIGINAL][dh->dccph_type][CT_DCCP_NONE];
+	state = dccp_state_table[CT_DCCP_ROLE_CLIENT][dh->dccph_type][CT_DCCP_NONE];
 	switch (state) {
 	default:
 		if (nf_ct_dccp_loose == 0) {
@@ -425,6 +435,8 @@ static int dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	}
 
 	ct->proto.dccp.state = CT_DCCP_NONE;
+	ct->proto.dccp.role[IP_CT_DIR_ORIGINAL] = CT_DCCP_ROLE_CLIENT;
+	ct->proto.dccp.role[IP_CT_DIR_REPLY] = CT_DCCP_ROLE_SERVER;
 	return 1;
 
 out_invalid:
@@ -446,8 +458,10 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		       unsigned int dataoff, enum ip_conntrack_info ctinfo,
 		       int pf, unsigned int hooknum)
 {
+	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	struct dccp_hdr _dh, *dh;
 	u_int8_t type, old_state, new_state;
+	enum ct_dccp_roles role;
 
 	dh = skb_header_pointer(skb, dataoff, sizeof(_dh), &dh);
 	BUG_ON(dh == NULL);
@@ -463,10 +477,20 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 
 	write_lock_bh(&dccp_lock);
 
+	role = ct->proto.dccp.role[dir];
 	old_state = ct->proto.dccp.state;
-	new_state = dccp_state_table[CTINFO2DIR(ctinfo)][type][old_state];
+	new_state = dccp_state_table[role][type][old_state];
 
 	switch (new_state) {
+	case CT_DCCP_REQUEST:
+		if (old_state == CT_DCCP_TIMEWAIT &&
+		    role == CT_DCCP_ROLE_SERVER) {
+			/* Reincarnation in the reverse direction: reopen and
+			 * reverse client/server roles. */
+			ct->proto.dccp.role[dir] = CT_DCCP_ROLE_CLIENT;
+			ct->proto.dccp.role[!dir] = CT_DCCP_ROLE_SERVER;
+		}
+		break;
 	case CT_DCCP_RESPOND:
 		if (old_state == CT_DCCP_REQUEST)
 			ct->proto.dccp.handshake_seq = dccp_hdr_seq(dh);

--------------020307000307030705080106--
