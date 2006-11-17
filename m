From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 18:03:32 +0000
Subject: [PATCH 6/7]: Migration to DCCP_CRIT
Message-Id: <200611171803.32851@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Wrapper for non-ratelimited error messages

This 
	* provides a wrapper for internal, functional errors
	* promotes some critical warning messages to use this wrapper
	* replaces the combination of printk + dump_stack with DCCP_BUG
	* is meant to aid in future code restructuring 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	  
---
 net/dccp/ackvec.c                  |    5 +----
 net/dccp/ccids/ccid3.c             |   21 +++++++--------------
 net/dccp/ccids/lib/loss_interval.c |    4 ++--
 net/dccp/minisocks.c               |    4 +---
 net/dccp/options.c                 |    5 ++---
 net/dccp/output.c                  |   16 +++++-----------
 net/dccp/proto.c                   |    5 ++---
 7 files changed, 20 insertions(+), 40 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -491,9 +491,6 @@ u64 dccp_ackvec_parse(struct sock *sk, u
 					       sk, ackno, len, value);
 }
 
-static char dccp_ackvec_slab_msg[] __initdata -	KERN_CRIT "DCCP: Unable to create ack vectors slab caches\n";
-
 int __init dccp_ackvec_init(void)
 {
 	dccp_ackvec_slab = kmem_cache_create("dccp_ackvec",
@@ -515,7 +512,7 @@ out_destroy_slab:
 	kmem_cache_destroy(dccp_ackvec_slab);
 	dccp_ackvec_slab = NULL;
 out_err:
-	printk(dccp_ackvec_slab_msg);
+	DCCP_CRIT("Unable to create Ack Vector slab cache");
 	return -ENOBUFS;
 }
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -393,9 +393,8 @@ static void ccid3_hc_tx_packet_sent(stru
 	case TFRC_SSTATE_NO_SENT:
 		/* if first wasn't pure ack */
 		if (len != 0)
-			printk(KERN_CRIT "%s: %s, First packet sent is noted "
-					 "as a data packet\n",
-			       __FUNCTION__, dccp_role(sk));
+			DCCP_CRIT("%s, First packet sent is noted "
+				  "as a data packet",  dccp_role(sk));
 		return;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
@@ -829,8 +828,7 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	}
 found:
 	if (!tail) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: tail is null\n",
-		   __FUNCTION__);
+		DCCP_CRIT("tail is null");
 		return ~0;
 	}
 	rtt = timeval_delta(&tstamp, &tail->dccphrx_tstamp) * 4 / interval;
@@ -851,9 +849,7 @@ found:
 	tmp2 = (u32)tmp1;
 
 	if (!tmp2) {
-		LIMIT_NETDEBUG(KERN_WARNING "tmp2 = 0 "
-		   "%s: x_recv = %u, rtt =%u\n",
-		   __FUNCTION__, x_recv, rtt);
+		DCCP_CRIT("tmp2 = 0, x_recv = %u, rtt =%u", x_recv, rtt);
 		return ~0;
 	}
 
@@ -899,8 +895,7 @@ static void ccid3_hc_rx_update_li(struct
 		entry = dccp_li_hist_entry_new(ccid3_li_hist, SLAB_ATOMIC);
 
 		if (entry = NULL) {
-			printk(KERN_CRIT "%s: out of memory\n",__FUNCTION__);
-			dump_stack();
+			DCCP_BUG("out of memory - can not allocate entry");
 			return;
 		}
 
@@ -1076,10 +1071,8 @@ static void ccid3_hc_rx_packet_recv(stru
 		/* Scaling up by 1000000 as fixed decimal */
 		if (i_mean != 0)
 			hcrx->ccid3hcrx_p = 1000000 / i_mean;
-	} else {
-		printk(KERN_CRIT "%s: empty loss hist\n",__FUNCTION__);
-		dump_stack();
-	}
+	} else
+		DCCP_BUG("empty loss history");
 
 	if (hcrx->ccid3hcrx_p > p_prev) {
 		ccid3_hc_rx_send_feedback(sk);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -239,9 +239,8 @@ int dccp_parse_options(struct sock *sk, 
 		}
 			break;
 		default:
-			pr_info("DCCP(%p): option %d(len=%d) not "
-				"implemented, ignoring\n",
-				sk, opt, len);
+			DCCP_CRIT("DCCP(%p): option %d(len=%d) not "
+				  "implemented, ignoring", sk, opt, len);
 			break;
 	        }
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1033,8 +1033,7 @@ static int __init dccp_init(void)
 	} while (!dccp_hashinfo.ehash && --ehash_order > 0);
 
 	if (!dccp_hashinfo.ehash) {
-		printk(KERN_CRIT "Failed to allocate DCCP "
-				 "established hash table\n");
+		DCCP_CRIT("Failed to allocate DCCP established hash table");
 		goto out_free_bind_bucket_cachep;
 	}
 
@@ -1056,7 +1055,7 @@ static int __init dccp_init(void)
 	} while (!dccp_hashinfo.bhash && --bhash_order >= 0);
 
 	if (!dccp_hashinfo.bhash) {
-		printk(KERN_CRIT "Failed to allocate DCCP bind hash table\n");
+		DCCP_CRIT("Failed to allocate DCCP bind hash table");
 		goto out_free_dccp_ehash;
 	}
 
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -13,7 +13,7 @@
 
 #include <linux/module.h>
 #include <net/sock.h>
-
+#include "../../dccp.h"
 #include "loss_interval.h"
 
 struct dccp_li_hist *dccp_li_hist_new(const char *name)
@@ -128,7 +128,7 @@ int dccp_li_hist_interval_new(struct dcc
 		entry = dccp_li_hist_entry_new(hist, SLAB_ATOMIC);
 		if (entry = NULL) {
 			dccp_li_hist_purge(hist, list);
-			dump_stack();
+			DCCP_BUG("loss interval list entry is NULL");
 			return 0;
 		}
 		entry->dccplih_interval = ~0;
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -289,9 +289,7 @@ EXPORT_SYMBOL_GPL(dccp_child_process);
 
 void dccp_reqsk_send_ack(struct sk_buff *skb, struct request_sock *rsk)
 {
-	pr_info(KERN_WARNING "DCCP: ACK packets are never sent in "
-			     "LISTEN/RESPOND state\n");
-	dump_stack();
+	DCCP_BUG("DCCP-ACK packets are never sent in LISTEN/RESPOND state");
 }
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_send_ack);
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -257,11 +257,8 @@ void dccp_write_xmit(struct sock *sk, in
 				err = dccp_wait_for_ccid(sk, skb, &timeo);
 				timeo = DCCP_XMIT_TIMEO;
 			}
-			if (err) {
-				printk(KERN_CRIT "%s:err at dccp_wait_for_ccid"
-						 " %d\n", __FUNCTION__, err);
-				dump_stack();
-			}
+			if (err)
+				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
 		}
 
 		skb_dequeue(&sk->sk_write_queue);
@@ -283,12 +280,9 @@ void dccp_write_xmit(struct sock *sk, in
 
 			err = dccp_transmit_skb(sk, skb);
 			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
-			if (err) {
-				printk(KERN_CRIT "%s:err from "
-					         "ccid_hc_tx_packet_sent %d\n",
-					         __FUNCTION__, err);
-				dump_stack();
-			}
+			if (err)
+				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
+					 err);
 		} else
 			kfree(skb);
 	}
