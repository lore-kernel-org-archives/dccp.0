From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 20 Dec 2008 08:08:08 +0000
Subject: [RFC] [Patch 1/4] dccp: Remove old CCID-module references
Message-Id: <20081220080808.GB3853@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: Remove module references

This removes module references of CCID modules, which are no longer
needed as the configured CCIDs are linked into dccp.ko.
 
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.c        |   12 ------------
 net/dccp/ccid.h        |    2 --
 net/dccp/ccids/ccid2.c |    1 -
 net/dccp/ccids/ccid3.c |    1 -
 4 files changed, 16 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -29,7 +29,6 @@ struct tcp_info;
  *  @ccid_id: numerical CCID ID (up to %CCID_MAX, cf. table 5 in RFC 4340, 10.)
  *  @ccid_ccmps: the CCMPS including network/transport headers (0 when disabled)
  *  @ccid_name: alphabetical identifier string for @ccid_id
- *  @ccid_owner: module which implements/owns this CCID
  *  @ccid_hc_{r,t}x_slab: memory pool for the receiver/sender half-connection
  *  @ccid_hc_{r,t}x_obj_size: size of the receiver/sender half-connection socket
  *
@@ -48,7 +47,6 @@ struct ccid_operations {
 	unsigned char		ccid_id;
 	__u32			ccid_ccmps;
 	const char		*ccid_name;
-	struct module		*ccid_owner;
 	struct kmem_cache	*ccid_hc_rx_slab,
 				*ccid_hc_tx_slab;
 	__u32			ccid_hc_rx_obj_size,
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -283,22 +283,14 @@ struct ccid *ccid_new(unsigned char id, 
 	if (ccid_ops = NULL)
 		goto out_unlock;
 
-	if (!try_module_get(ccid_ops->ccid_owner))
-		goto out_unlock;
-
 	ccids_read_unlock();
 
 	ccid = __ccid_new(ccid_ops, sk, rx, gfp);
-	if (ccid = NULL)
-		goto out_module_put;
 out:
 	return ccid;
 out_unlock:
 	ccids_read_unlock();
 	goto out;
-out_module_put:
-	module_put(ccid_ops->ccid_owner);
-	goto out;
 }
 
 EXPORT_SYMBOL_GPL(ccid_new);
@@ -320,10 +312,6 @@ static void ccid_delete(struct ccid *cci
 			ccid_ops->ccid_hc_tx_exit(sk);
 		kmem_cache_free(ccid_ops->ccid_hc_tx_slab,  ccid);
 	}
-	ccids_read_lock();
-	if (ccids[ccid_ops->ccid_id] != NULL)
-		module_put(ccid_ops->ccid_owner);
-	ccids_read_unlock();
 }
 
 void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk)
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -771,7 +771,6 @@ static void ccid2_hc_rx_packet_recv(stru
 struct ccid_operations ccid2_ops = {
 	.ccid_id		= DCCPC_CCID2,
 	.ccid_name		= "TCP-like",
-	.ccid_owner		= THIS_MODULE,
 	.ccid_hc_tx_obj_size	= sizeof(struct ccid2_hc_tx_sock),
 	.ccid_hc_tx_init	= ccid2_hc_tx_init,
 	.ccid_hc_tx_exit	= ccid2_hc_tx_exit,
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -943,7 +943,6 @@ static int ccid3_hc_rx_getsockopt(struct
 struct ccid_operations ccid3_ops = {
 	.ccid_id		   = DCCPC_CCID3,
 	.ccid_name		   = "TCP-Friendly Rate Control",
-	.ccid_owner		   = THIS_MODULE,
 	.ccid_hc_tx_obj_size	   = sizeof(struct ccid3_hc_tx_sock),
 	.ccid_hc_tx_init	   = ccid3_hc_tx_init,
 	.ccid_hc_tx_exit	   = ccid3_hc_tx_exit,
