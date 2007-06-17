From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 10:22:49 +0000
Subject: Re: [PATCH 5/6]: Add history query/lookup function
Message-Id: <200706171122.49682@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706111342.02233@strip-the-willow>
In-Reply-To: <200706111342.02233@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

 |  I notice there is other functionality here also...
|  
|  > +/**
|  > + *  tfrc_tx_hist_when  -  Retrieve send time of past packet
|  > + *  If successful, it garbage-collects older (irrelevant) entries and returns 1.
|  > + */
|  > +int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
|  > +{
|  > +
|  > +       if (tail)
|  > +               __tfrc_tx_hist_remove_tail(tail, head->cache);
|  > +
|  
|  Can you explain the rationale behind this?
|  
You have cut out half of the code, I therefore need to copy again below:

+int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
+{
+	struct tfrc_tx_hist *cur, *tail = NULL;
+
+	write_lock_bh(&tfrc_tx_hist_lock);
+	for (cur = head->first; cur != NULL; cur = cur->next)
+		if (cur->seqno = ackno) {
+			*stamp = cur->stamp;
+			tail = cur->next;
+			cur->next = NULL;
+			break;
+		}
+	write_unlock_bh(&tfrc_tx_hist_lock);
+
+	if (tail)
+		__tfrc_tx_hist_remove_tail(tail, head->cache);
+
+	return (cur != NULL);
+}

The patch first performs a lookup. If the lookup is successful, tail != NULL and 
all entries older than `cur' (LIFO order) are cut off; at the same time tail is set
to the `tail' starting at the now old/obsolete entries.

Removing the tail is not done when under lock, since this may take time (you never
know how long the list is). So this uses a common trick of first `orphaning' the
old tail, and then doing the cleanup outside the lock-protected region, when there
is more time to do so.

Maybe you have noted that the subsequent patch (6/6) has the following hunk:

@@ -492,9 +488,6 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* unschedule no feedback timer */
 		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-		/* remove all packets older than the one acked from history */
-		dccp_tx_hist_purge_older(ccid3_tx_hist,
-					 &hctx->ccid3hctx_hist, packet);
 		/*
 		 * As we have calculated new ipi, delta, t_nom it is possible
 		 * that we now can send a packet, so wake up dccp_wait_for_ccid

=> The above effectively replaces this in one go. This is better since otherwise
   the same lock would need to be acquired twice - once for reading, then for
   writing (to perform the purge). This would introduce a race condition.
  

=> You can find this also in the documentation of patch 5/6:

+ *  tfrc_tx_hist_when  -  Retrieve send time of past packet
+
+ *  If successful, it garbage-collects older (irrelevant) entries and returns 1.
+ */
