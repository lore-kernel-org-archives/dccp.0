From: Patrick McHardy <kaber@trash.net>
Date: Tue, 08 Apr 2008 14:12:14 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <47FB7D3E.4060703@trash.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------060801050805000009060701"
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--------------060801050805000009060701
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Gerrit Renker wrote:
>>     State Transitions in the original direction
>>     ===========================================
>>
>>  * DCCP-Request:
>>    - in state Respond (sRS -> sRS), the Request is illegal (Respond 
>> is server state)
>
>>    - also, the CLOSEREQ state transition (sCR -> sIG) is illegal: 
>> Requests are sent      by clients only, and CLOSEREQ can only be 
>> entered by servers
>
> We track both sides, so we must also define which client packets
> are valid in which server state. This particular one is part of
> the unfinished resync feature. The firewall might be out of sync
> with both endpoints. If connection pickup is enabled it should
> let packets that might establish a new connection pass and resync
> when the other side responds with a valid Response. I need to
> think about this a bit more, but I've marked it with FIXME for
> now :)

I've added this patch on top to handle the out-of-sync case by
letting Requests pass in (almost) any state and resyncing when
seeing a valid Response.

Last TODO before the DCCP_LISTEN support is to fix connection
pickup for established connections. Since it doesn't see the
initial Request/Response it doesn't know which side has which
role and also can't properly pick an inital state.

--------------060801050805000009060701
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/linux/netfilter/nf_conntrack_dccp.h b/include/linux/netfilter/nf_conntrack_dccp.h
index 41ffdf8..40dcc82 100644
--- a/include/linux/netfilter/nf_conntrack_dccp.h
+++ b/include/linux/netfilter/nf_conntrack_dccp.h
@@ -30,6 +30,8 @@ enum ct_dccp_roles {
 struct nf_ct_dccp {
 	u_int8_t	role[IP_CT_DIR_MAX];
 	u_int8_t	state;
+	u_int8_t	last_pkt;
+	u_int8_t	last_dir;
 	u_int64_t	handshake_seq;
 };
 
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index a89113d..96bd70c 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -147,10 +147,10 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 		 * sRQ -> sRQ		Retransmitted Request or reincarnation
 		 * sRS -> sRS		Retransmitted Request (apparently Response
 		 * 			got lost after we saw it) or reincarnation
-		 * sPO -> sIG		Request during PARTOPEN state, server will ignore it
-		 * sOP -> sIG		Request during OPEN state: server will ignore it
-		 * sCR -> sIG		FIXME MUST respond with Close to CloseReq (8.3.)
-		 * sCG -> sIG
+		 * sPO -> sIG		Ignore, conntrack might be out of sync
+		 * sOP -> sIG		Ignore, conntrack might be out of sync
+		 * sCR -> sIG		Ignore, conntrack might be out of sync
+		 * sCG -> sIG		Ignore, conntrack might be out of sync
 		 * sTW -> sRQ		Reincarnation
 		 *
 		 *	sNO, sRQ, sRS, sPO. sOP, sCR, sCG, sTW, */
@@ -158,10 +158,18 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 		},
 		[DCCP_PKT_RESPONSE] = {
 		/*
-		 * A Response from the client is always invalid.
+		 * sNO -> sIV		Invalid
+		 * sRQ -> sIG		Ignore, might be response to ignored Request
+		 * sRS -> sIG		Ignore, might be response to ignored Request
+		 * sPO -> sIG		Ignore, might be response to ignored Request
+		 * sOP -> sIG		Ignore, might be response to ignored Request
+		 * sCR -> sIG		Ignore, might be response to ignored Request
+		 * sCG -> sIG		Ignore, might be response to ignored Request
+		 * sTW -> sIV		Invalid, reincarnation in reverse direction
+		 *			goes through sRQ
 		 *
 		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
-			sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV,
+			sIV, sIG, sIG, sIG, sIG, sIG, sIG, sIV,
 		},
 		[DCCP_PKT_ACK] = {
 		/*
@@ -258,20 +266,17 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 	[CT_DCCP_ROLE_SERVER] = {
 		[DCCP_PKT_REQUEST] = {
 		/*
-		 * A Request from the server is only valid for reopening a
-		 * connection in TIMEWAIT state.
-		 *
-		 * sNO -> sIV
-		 * sRQ -> sIV
-		 * sRS -> sIV
-		 * sPO -> sIV
-		 * sOP -> sIV
-		 * sCR -> sIV
-		 * sCG -> sIV
+		 * sNO -> sIV		Invalid
+		 * sRQ -> sIG		Ignore, conntrack might be out of sync
+		 * sRS -> sIG		Ignore, conntrack might be out of sync
+		 * sPO -> sIG		Ignore, conntrack might be out of sync
+		 * sOP -> sIG		Ignore, conntrack might be out of sync
+		 * sCR -> sIG		Ignore, conntrack might be out of sync
+		 * sCG -> sIG		Ignore, conntrack might be out of sync
 		 * sTW -> sRQ		Reincarnation, must reverse roles
 		 *
 		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
-			sIV, sIV, sIV, sIV, sIV, sIV, sIV, sRQ
+			sIV, sIG, sIG, sIG, sIG, sIG, sIG, sRQ
 		},
 		[DCCP_PKT_RESPONSE] = {
 		/*
@@ -279,13 +284,13 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 		 * sRQ -> sRS		Response to clients Request
 		 * sRS -> sRS		Retransmitted Response (8.1.3. SHOULD NOT)
 		 * sPO -> sIG		Response to an ignored Request or late retransmit
-		 * sOP -> sIG		Invalid
-		 * sCR -> sIG		Invalid
-		 * sCG -> sIG		Invalid
-		 * sTW -> sIG		Invalid
+		 * sOP -> sIG		Ignore, might be response to ignored Request
+		 * sCR -> sIG		Ignore, might be response to ignored Request
+		 * sCG -> sIG		Ignore, might be response to ignored Request
+		 * sTW -> sIV		Invalid, Request from client in sTW moves to sRQ
 		 *
 		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
-			sIV, sRS, sRS, sIG, sIG, sIG, sIG, sIG
+			sIV, sRS, sRS, sIG, sIG, sIG, sIG, sIV
 		},
 		[DCCP_PKT_ACK] = {
 		/*
@@ -503,6 +508,20 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 			set_bit(IPS_ASSURED_BIT, &ct->status);
 		break;
 	case CT_DCCP_IGNORE:
+		/*
+		 * Connection tracking might be out of sync, so we ignore
+		 * packets that might establish a new connection and resync
+		 * if the server responds with a valid Response.
+		 */
+		if (ct->proto.dccp.last_dir == !dir &&
+		    ct->proto.dccp.last_pkt == DCCP_PKT_REQUEST &&
+		    type == DCCP_PKT_RESPONSE) {
+			ct->proto.dccp.role[!dir] = CT_DCCP_ROLE_CLIENT;
+			ct->proto.dccp.role[dir] = CT_DCCP_ROLE_SERVER;
+			ct->proto.dccp.handshake_seq = dccp_hdr_seq(dh);
+			new_state = CT_DCCP_RESPOND;
+			break;
+		}
 		write_unlock_bh(&dccp_lock);
 		if (LOG_INVALID(IPPROTO_DCCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
@@ -516,6 +535,8 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		return -NF_ACCEPT;
 	}
 
+	ct->proto.dccp.last_dir = dir;
+	ct->proto.dccp.last_pkt = type;
 	ct->proto.dccp.state = new_state;
 	write_unlock_bh(&dccp_lock);
 	nf_ct_refresh_acct(ct, ctinfo, skb, dccp_timeout[new_state]);

--------------060801050805000009060701--
