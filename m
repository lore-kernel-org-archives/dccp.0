From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 18 May 2008 16:09:01 +0000
Subject: Re: Reporting possible bug in DCCP Feature negotiation
Message-Id: <20080518160901.GA21382@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
In-Reply-To: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
To: dccp@vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Leandro,

I can now confirm that this is indeed a bug. It is caused by the client
not retransmitting Confirm options while in state PARTOPEN.

A detailed analysis with capture files has been uploaded to
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/why_retransmit_confirms/

The fix is to retransmit Confirm options until entering OPEN state.
A patch is attached and has been put into the test tree.

There is another bug fix involved, this is documented on the website,
will send second patch subsequently.

Many thanks for testing and reporting.
Gerrit

| Hi Gerrit, during some experiments using iperf to transmit one TCP
| flow against 3 DCCP flows, one DCCP thread stopped and it was shown
| the following message:
| 
| "[ 6286.864021] BUG: Failed negotiation in state 2 at
| net/dccp/feat.c:1370/dccp_feat_activate_values()"
| 
| Here it is the complete debug msgs including the dumped stack at the
| time the error occurred:
| 
| {...}
| [ 6286.864021] BUG: Failed negotiation in state 2 at
| net/dccp/feat.c:1370/dccp_feat_activate_values()
| [ 6286.864034] Pid: 0, comm: swapper Not tainted 2.6.25-rc3 #4
| [ 6286.864034]  [<c045c6bb>] dccp_feat_activate_values+0x7b/0x200
| [ 6286.864034]  [<c045f919>] dccp_create_openreq_child+0xb9/0x100
| [ 6286.864034]  [<c0465226>] dccp_v4_request_recv_sock+0x46/0x1b0
| [ 6286.864034]  [<c045f72e>] dccp_check_req+0x24e/0x380
| [ 6286.864034]  [<c04526b0>] ipt_hook+0x0/0x20
| [ 6286.864034]  [<c046543a>] dccp_v4_do_rcv+0xaa/0x160
| [ 6286.864034]  [<c03fb560>] sk_receive_skb+0xc0/0x110
| [ 6286.864034]  [<c04216c6>] ip_local_deliver_finish+0x66/0x120
| [ 6286.864034]  [<c0421660>] ip_local_deliver_finish+0x0/0x120
| [ 6286.864034]  [<c042144b>] ip_rcv_finish+0xfb/0x310
| [ 6286.864034]  [<c045b9b6>] packet_rcv_spkt+0x36/0x160
| [ 6286.864034]  [<c0421880>] ip_rcv+0x0/0x290
| [ 6286.864034]  [<c04028ed>] netif_receive_skb+0x19d/0x230
| [ 6286.864034]  [<c0405133>] process_backlog+0x63/0xd0
| [ 6286.864034]  [<c0404a99>] net_rx_action+0x89/0x180
| [ 6286.864034]  [<c01263e2>] __do_softirq+0x72/0xf0
| [ 6286.864034]  [<c0126497>] do_softirq+0x37/0x40
| [ 6286.864034]  [<c01065b0>] do_IRQ+0x40/0x70
| [ 6286.864034]  [<c0104b1f>] common_interrupt+0x23/0x28
| [ 6286.864034]  [<c01300d8>] sys_setdomainname+0x58/0xb0
| [ 6286.864034]  [<c0102d92>] default_idle+0x52/0x80
| [ 6286.864034]  [<c0102d40>] default_idle+0x0/0x80
| [ 6286.864034]  [<c0102bdd>] cpu_idle+0x4d/0xd0
| [ 6286.864034]  =======================

--liOOAslEiF7prFVr
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="DCCP_BUG-FIX_Client-send-Confirms-until-OPEN.diff"

[DCCP]: Bug-fix for feature-negotiation

This fixes an issue in client feature-negotiation: as long as the client is in
PARTOPEN, it needs to retransmit the Confirm options for the Change options
received on the DCCP-Response from the server.

Otherwise, if the packet containing the Confirm options gets dropped in the 
network, the connection aborts due to undefined feature negotiation state.

This patch fixes the problem by flushing the client queue only when entering
the OPEN state. Since confirmed Change options are removed as soon as they
are confirmed (in the DCCP-Response), this ensures that Confirm options are
retransmitted.

The remainder of the patch serves to make problem reporting more informative
when feature negotiation has failed.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c  |   25 +++++++++++++------------
 net/dccp/proto.c |    3 +++
 2 files changed, 16 insertions(+), 12 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -67,6 +67,9 @@ void dccp_set_state(struct sock *sk, con
 	case DCCP_OPEN:
 		if (oldstate != DCCP_OPEN)
 			DCCP_INC_STATS(DCCP_MIB_CURRESTAB);
+		/* Client retransmits all Confirm options until entering OPEN */
+		if (oldstate == DCCP_PARTOPEN)
+			dccp_feat_list_purge(&dccp_sk(sk)->dccps_featneg);
 		break;
 
 	case DCCP_CLOSED:
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -639,16 +639,10 @@ int dccp_feat_insert_opts(struct dccp_so
 		if (pos->needs_mandatory && dccp_insert_option_mandatory(skb))
 			return -1;
 		/*
-		 * Keeping State: Enter CHANGING state after transmitting the
-		 * Change option (6.6.2). Furthermore, Confirm options are not
-		 * retransmitted (6.2) - with the exception of request sockets,
-		 * where removal of the confirmed entry is deferred until the
-		 * child socket has been created.
+		 * Enter CHANGING after transmitting the Change option (6.6.2).
 		 */
 		if (pos->state == FEAT_INITIALISING)
 			pos->state = FEAT_CHANGING;
-		else if (pos->needs_confirm && dreq == NULL)
-			dccp_feat_list_pop(pos);
 	}
 	return 0;
 }
@@ -1456,8 +1450,15 @@ int dccp_feat_activate_values(struct soc
 	list_for_each_entry(cur, fn_list, node) {
 
 		idx = dccp_feat_index(cur->feat_num);
-		if (cur->state != FEAT_STABLE || idx < 0) {
-			DCCP_BUG("Failed negotiation in state %u", cur->state);
+		if (idx < 0) {
+			DCCP_BUG("Unknown feature %u", cur->feat_num);
+			goto activation_failed;
+		}
+		if (cur->state != FEAT_STABLE) {
+			DCCP_CRIT("Negotiation of %s %s failed in state %s",
+				  cur->is_local ? "local" : "remote",
+				  dccp_feat_fname(cur->feat_num),
+				  dccp_feat_sname[cur->state]);
 			goto activation_failed;
 		}
 		fvals[idx][cur->is_local] = &cur->val;
@@ -1471,8 +1472,10 @@ int dccp_feat_activate_values(struct soc
 	 */
 	for (idx = DCCP_FEAT_SUPPORTED_MAX; --idx >= 0;)
 		if (__dccp_feat_activate(sk, idx, 0, fvals[idx][0]) ||
-		    __dccp_feat_activate(sk, idx, 1, fvals[idx][1]))
+		    __dccp_feat_activate(sk, idx, 1, fvals[idx][1])) {
+			DCCP_CRIT("Could not activate %d", idx);
 			goto activation_failed;
+		}
 
 	/* Clean up Change options which have been confirmed already */
 	list_for_each_entry_safe(cur, next, fn_list, node)
@@ -1483,8 +1486,6 @@ int dccp_feat_activate_values(struct soc
 	return 0;
 
 activation_failed:
-	DCCP_CRIT("Activation of %s failed", idx < 0 ? "unknown feature" :
-		  dccp_feat_fname(dccp_feat_table[idx].feat_num));
 	/*
 	 * We clean up everything that may have been allocated, since
 	 * it is difficult to track at which stage negotiation failed.

--liOOAslEiF7prFVr--
