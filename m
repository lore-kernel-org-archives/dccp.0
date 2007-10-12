From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 12 Oct 2007 09:51:48 +0000
Subject: [PATCH 1/5]: Documentation for CCID operations
Message-Id: <200710121051.48742@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Documentation for CCID operations

This adds documentation for the ccid_operations structure.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h |   35 ++++++++++++++++++++++++++++-------
 1 file changed, 28 insertions(+), 7 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -23,14 +23,35 @@
 
 struct tcp_info;
 
+/**
+ *  struct ccid_operations  -  Interface to Congestion-Control Infrastructure
+ *
+ *  @ccid_id: numerical CCID ID (up to %CCID_MAX, cf. table 5 in RFC 4340, 10.)
+ *  @ccid_name: alphabetical identifier string for @ccid_id
+ *  @ccid_owner: module which implements/owns this CCID
+ *  @ccid_hc_{r,t}x_slab: memory pool for the receiver/sender half-connection
+ *  @ccid_hc_{r,t}x_obj_size: size of the receiver/sender half-connection socket
+ *
+ *  @ccid_hc_{r,t}x_init: CCID-specific initialisation routine (before startup)
+ *  @ccid_hc_{r,t}x_exit: CCID-specific cleanup routine (before destruction)
+ *  @ccid_hc_rx_packet_recv: implements the HC-receiver side
+ *  @ccid_hc_{r,t}x_parse_options: parsing routine for CCID/HC-specific options
+ *  @ccid_hc_{r,t}x_insert_options: insert routine for CCID/HC-specific options
+ *  @ccid_hc_tx_packet_recv: implements feedback processing for the HC-sender
+ *  @ccid_hc_tx_send_packet: implements the sending part of the HC-sender
+ *  @ccid_hc_tx_packet_sent: does accounting for packets in flight by HC-sender
+ *  @ccid_hc_{r,t}x_get_info: INET_DIAG information for HC-receiver/sender
+ *  @ccid_hc_{r,t}x_getsockopt: socket options specific to HC-receiver/sender
+ */
 struct ccid_operations {
-	unsigned char	ccid_id;
-	const char	*ccid_name;
-	struct module	*ccid_owner;
-	struct kmem_cache	*ccid_hc_rx_slab;
-	__u32		ccid_hc_rx_obj_size;
-	struct kmem_cache	*ccid_hc_tx_slab;
-	__u32		ccid_hc_tx_obj_size;
+	unsigned char		ccid_id;
+	const char		*ccid_name;
+	struct module		*ccid_owner;
+	struct kmem_cache	*ccid_hc_rx_slab,
+				*ccid_hc_tx_slab;
+	__u32			ccid_hc_rx_obj_size,
+				ccid_hc_tx_obj_size;
+	/* Interface Routines */
 	int		(*ccid_hc_rx_init)(struct ccid *ccid, struct sock *sk);
 	int		(*ccid_hc_tx_init)(struct ccid *ccid, struct sock *sk);
 	void		(*ccid_hc_rx_exit)(struct sock *sk);
