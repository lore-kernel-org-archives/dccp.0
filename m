From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:55 +0000
Subject: [PATCH 14/14] [ACKVEC]: Remove old infrastructure
Message-Id: <1198074355-18842-15-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes
 * functions for which updates have been provided in the preceding patches and
 * the @av_vec_len field - it is no longer necessary since the buffer length is
   now always computed dynamically;
 * conditional debugging code (CONFIG_IP_DCCP_ACKVEC).

The reason for removing the latter is that Ack Vectors are an almost
inevitable necessity - RFC 4341 says if you use CCID2, Ack Vectors
must be used. Furthermore, the code would be only interesting for going
bug-hunting. Having dealt with several bugs/problems in the code already,
I am positive that the old debugging code is no longer necessary.

Also updated copyrights.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/Kconfig       |    3 -
 net/dccp/Makefile      |    5 +-
 net/dccp/ackvec.c      |  141 +-----------------------------------------------
 net/dccp/ackvec.h      |   64 +---------------------
 net/dccp/ccids/Kconfig |    1 -
 5 files changed, 7 insertions(+), 207 deletions(-)

--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -25,9 +25,6 @@ config INET_DCCP_DIAG
 	def_tristate y if (IP_DCCP = y && INET_DIAG = y)
 	def_tristate m
 
-config IP_DCCP_ACKVEC
-	bool
-
 source "net/dccp/ccids/Kconfig"
 
 menu "DCCP Kernel Hacking"
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
-dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o
+dccp-y := ccid.o feat.o input.o minisocks.o options.o \
+	  output.o proto.o timer.o ackvec.o
 
 dccp_ipv4-y := ipv4.o
 
@@ -8,8 +9,6 @@ dccp_ipv4-y := ipv4.o
 obj-$(subst y,$(CONFIG_IP_DCCP),$(CONFIG_IPV6)) += dccp_ipv6.o
 dccp_ipv6-y := ipv6.o
 
-dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.o
-
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o
 obj-$(CONFIG_NET_DCCPPROBE) += dccp_probe.o
 
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -1,26 +1,18 @@
 /*
  *  net/dccp/ackvec.c
  *
- *  An implementation of the DCCP protocol
+ *  An implementation of Ack Vectors for the DCCP protocol
+ *  Copyright (c) 2007 University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
  *
  *      This program is free software; you can redistribute it and/or modify it
  *      under the terms of the GNU General Public License as published by the
  *      Free Software Foundation; version 2 of the License;
  */
-
-#include "ackvec.h"
 #include "dccp.h"
-
-#include <linux/dccp.h>
-#include <linux/init.h>
-#include <linux/errno.h>
 #include <linux/kernel.h>
-#include <linux/skbuff.h>
 #include <linux/slab.h>
 
-#include <net/sock.h>
-
 static struct kmem_cache *dccp_ackvec_slab;
 static struct kmem_cache *dccp_ackvec_record_slab;
 
@@ -31,7 +23,6 @@ struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 	if (av != NULL) {
 		av->av_buf_head	= av->av_buf_tail = DCCPAV_MAX_ACKVEC_LEN - 1;
 		av->av_overflow = 0;
-		av->av_vec_len	 = 0;
 		memset(av->av_buf_nonce, 0, sizeof(av->av_buf_nonce));
 		INIT_LIST_HEAD(&av->av_records);
 	}
@@ -257,134 +248,6 @@ void dccp_ackvec_input(struct dccp_ackvec *av, u64 seqno, u8 state)
 	}
 }
 
-/*
- * If several packets are missing, the HC-Receiver may prefer to enter multiple
- * bytes with run length 0, rather than a single byte with a larger run length;
- * this simplifies table updates if one of the missing packets arrives.
- */
-static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
-						 const unsigned int packets,
-						 const unsigned char state)
-{
-	unsigned int gap;
-	long new_head;
-
-	if (av->av_vec_len + packets > DCCPAV_MAX_ACKVEC_LEN)
-		return -ENOBUFS;
-
-	gap	 = packets - 1;
-	new_head = av->av_buf_head - packets;
-
-	if (new_head < 0) {
-		if (gap > 0) {
-			memset(av->av_buf, DCCPAV_NOT_RECEIVED,
-			       gap + new_head + 1);
-			gap = -new_head;
-		}
-		new_head += DCCPAV_MAX_ACKVEC_LEN;
-	}
-
-	av->av_buf_head = new_head;
-
-	if (gap > 0)
-		memset(av->av_buf + av->av_buf_head + 1,
-		       DCCPAV_NOT_RECEIVED, gap);
-
-	av->av_buf[av->av_buf_head] = state;
-	av->av_vec_len += packets;
-	return 0;
-}
-
-/*
- * Implements the RFC 4340, Appendix A
- */
-int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
-		    const u64 ackno, const u8 state)
-{
-	u8 *cur_head = av->av_buf + av->av_buf_head,
-	   *buf_end  = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
-	/*
-	 * Check at the right places if the buffer is full, if it is, tell the
-	 * caller to start dropping packets till the HC-Sender acks our ACK
-	 * vectors, when we will free up space in av_buf.
-	 *
-	 * We may well decide to do buffer compression, etc, but for now lets
-	 * just drop.
-	 *
-	 * From Appendix A.1.1 (`New Packets'):
-	 *
-	 *	Of course, the circular buffer may overflow, either when the
-	 *	HC-Sender is sending data at a very high rate, when the
-	 *	HC-Receiver's acknowledgements are not reaching the HC-Sender,
-	 *	or when the HC-Sender is forgetting to acknowledge those acks
-	 *	(so the HC-Receiver is unable to clean up old state). In this
-	 *	case, the HC-Receiver should either compress the buffer (by
-	 *	increasing run lengths when possible), transfer its state to
-	 *	a larger buffer, or, as a last resort, drop all received
-	 *	packets, without processing them whatsoever, until its buffer
-	 *	shrinks again.
-	 */
-
-	/* See if this is the first ackno being inserted */
-	if (av->av_vec_len = 0) {
-		*cur_head = state;
-		av->av_vec_len = 1;
-	} else if (after48(ackno, av->av_buf_ackno)) {
-		const u64 delta = dccp_delta_seqno(av->av_buf_ackno, ackno);
-
-		/*
-		 * Look if the state of this packet is the same as the
-		 * previous ackno and if so if we can bump the head len.
-		 */
-		if (delta = 1 && dccp_ackvec_state(cur_head) = state &&
-		    dccp_ackvec_runlen(cur_head) < DCCPAV_MAX_RUNLEN)
-			*cur_head += 1;
-		else if (dccp_ackvec_set_buf_head_state(av, delta, state))
-			return -ENOBUFS;
-	} else {
-		/*
-		 * A.1.2.  Old Packets
-		 *
-		 *	When a packet with Sequence Number S <= buf_ackno
-		 *	arrives, the HC-Receiver will scan the table for
-		 *	the byte corresponding to S. (Indexing structures
-		 *	could reduce the complexity of this scan.)
-		 */
-		u64 delta = dccp_delta_seqno(ackno, av->av_buf_ackno);
-
-		while (1) {
-			const u8 len = dccp_ackvec_runlen(cur_head);
-			/*
-			 * valid packets not yet in av_buf have a reserved
-			 * entry, with a len equal to 0.
-			 */
-			if (*cur_head = DCCPAV_NOT_RECEIVED && delta = 0) {
-				dccp_pr_debug("Found %llu reserved seat!\n",
-					      (unsigned long long)ackno);
-				*cur_head = state;
-				goto out;
-			}
-			/* len = 0 means one packet */
-			if (delta < len + 1)
-				goto out_duplicate;
-
-			delta -= len + 1;
-			if (++cur_head = buf_end)
-				cur_head = av->av_buf;
-		}
-	}
-
-	av->av_buf_ackno = ackno;
-out:
-	return 0;
-
-out_duplicate:
-	/* Duplicate packet */
-	dccp_pr_debug("Received a dup or already considered lost "
-		      "packet: %llu\n", (unsigned long long)ackno);
-	return -EILSEQ;
-}
-
 /**
  * dccp_ackvec_clear_state  -  Perform house-keeping / garbage-collection
  * This routine is called when the peer acknowledges the receipt of Ack Vectors
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -3,9 +3,9 @@
 /*
  *  net/dccp/ackvec.h
  *
- *  An implementation of the DCCP protocol
+ *  An implementation of Ack Vectors for the DCCP protocol
+ *  Copyright (c) 2007 University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@mandriva.com>
- *
  *	This program is free software; you can redistribute it and/or modify it
  *	under the terms of the GNU General Public License version 2 as
  *	published by the Free Software Foundation.
@@ -59,7 +59,6 @@ static inline u8 dccp_ackvec_state(const u8 *cell)
  *		   %DCCP_SINGLE_OPT_MAXLEN cells in the live portion of @av_buf
  * @av_overflow:   if 1 then buf_head = buf_tail indicates buffer wraparound
  * @av_records:	   list of %dccp_ackvec_record (Ack Vectors sent previously)
- * @av_veclen:	   length of the live portion of @av_buf
  */
 struct dccp_ackvec {
 	u8			av_buf[DCCPAV_MAX_ACKVEC_LEN];
@@ -70,7 +69,6 @@ struct dccp_ackvec {
 	bool			av_buf_nonce[DCCPAV_NUM_ACKVECS];
 	u8			av_overflow:1;
 	struct list_head	av_records;
-	u16			av_vec_len;
 };
 
 /** struct dccp_ackvec_record - Records information about sent Ack Vectors
@@ -96,19 +94,12 @@ struct dccp_ackvec_record {
 	u8		 avr_ack_nonce:1;
 };
 
-struct sock;
-struct sk_buff;
-
-#ifdef CONFIG_IP_DCCP_ACKVEC
-extern int dccp_ackvec_init(void);
+extern int  dccp_ackvec_init(void);
 extern void dccp_ackvec_exit(void);
 
 extern struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority);
 extern void dccp_ackvec_free(struct dccp_ackvec *av);
 
-extern int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
-			   const u64 ackno, const u8 state);
-
 extern void dccp_ackvec_input(struct dccp_ackvec *av, u64 seqno, u8 state);
 extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
 extern void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
@@ -118,53 +109,4 @@ static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
 {
 	return av->av_overflow = 0 && av->av_buf_head = av->av_buf_tail;
 }
-#else /* CONFIG_IP_DCCP_ACKVEC */
-static inline int dccp_ackvec_init(void)
-{
-	return 0;
-}
-
-static inline void dccp_ackvec_exit(void)
-{
-}
-
-static inline struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
-{
-	return NULL;
-}
-
-static inline void dccp_ackvec_free(struct dccp_ackvec *av)
-{
-}
-
-static inline void dccp_ackvec_input(struct dccp_ackvec *av, u64 seq, u8 state)
-{
-
-}
-
-static inline int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
-				  const u64 ackno, const u8 state)
-{
-	return -1;
-}
-
-static inline void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno)
-{
-}
-
-static inline int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 nonce)
-{
-	return -1;
-}
-
-static inline u16 dccp_ackvec_buflen(const struct dccp_ackvec *av)
-{
-	return 0;
-}
-
-static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
-{
-	return true;
-}
-#endif /* CONFIG_IP_DCCP_ACKVEC */
 #endif /* _ACKVEC_H */
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -4,7 +4,6 @@ menu "DCCP CCIDs Configuration (EXPERIMENTAL)"
 config IP_DCCP_CCID2
 	tristate "CCID2 (TCP-Like) (EXPERIMENTAL)"
 	def_tristate IP_DCCP
-	select IP_DCCP_ACKVEC
 	---help---
 	  CCID 2, TCP-like Congestion Control, denotes Additive Increase,
 	  Multiplicative Decrease (AIMD) congestion control with behavior
-- 
1.5.3.GIT

