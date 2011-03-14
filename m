From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 14 Mar 2011 11:55:01 +0000
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
Message-Id: <20110314115501.GB4631@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
List-Id: <dccp.vger.kernel.org>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
To: dccp@vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Thank you for the comments, there is also some update (attached).


| > Well done, this looks good. I did some minor editing:
| >  * whitespace/formatting/comments,
| >  * simplification/subsumption,
| >  * function should not be called for non-NN or non-known
| >    feature, hence turned that into a DCCP_BUG() condition.
| 
| Okay
| 
I revised this some more, the function remains the same, but it is shorter 
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=94da7d70003e8185fe189146f336db72c8fa1f0b

(If there is disagreement regarding allowing a get_nn_ function to query non-nn
 features, I will add the test for type == NN back in.)


| >  1) Since ccid2_ack_ratio_next(sk) is just a wrapper around
| >     dccp_feat_get_nn_next_val(sk, DCCPF_ACK_RATIO), ok to
| >     use this instead?
| 
| It's just fine to use dccp_feat_get_nn_next_val() instead. My primary
| reason for creating ccid2_ack_ratio_next() was to keep line lengths
| down.
| 
Perhaps a shorter name, e.g.    dccp_feat_nn_get()
(since it returns either the current or next value, and there is no other
 accessor function defined).



| >  3) There is room for some refactoring:
| >     a) dccp_feat_signal_nn_change() always implies also in part
| >        dccp_feat_get_nn_next_val(): if the latter function returns
| >        the same value as the supposedly 'new' one, it is not
| >        necessary to start a new negotiation. So all the repeated
| >        tests could be folded into that function.
| 
| 
| The problem here is that the ack ratio should only be changed after a
| loss, idle period, etc if the new cwnd is going to be less than the
| (negotiating) ack ratio. We need to call dccp_feat_get_nn_next_val() to
| decide whether we need to adjust the ack ratio or not.
|
That is a good point, maybe I need to reread the patch again. From what I saw,
dccp_nn_get_next_val() is so far only called immediately before changing the
value, whereas the above comment hints more at a peek/read-only functionality.

This understanding was also the basis of the attached patch - actually I was
quite happy since its use further simplified the interface.

I think once the above is resolved (which also includes the point below), then
there is quite a good milestone for ccid-2.

| We don't want to change the ack ratio every time we have a loss, etc.
| Doing so will result in pointless negotiations and more fluctuations in
| the ack ratio, neither of which is desirable.
| 
Agree, having done some testing over the weekend I found that some kind of
hysteresis would be desirable.

I don't know if blocking the Ack Ratio code is the reason, but during the
initial slow-start there were ChangeL requests for Sequence Window on nearly
every packet, which seems too much.

If low_threshold == high_threshold, it oscillates. I think you have already done
some work on this in the code using CCID2_WIN_CHANGE_FACTOR.

During steady state of the connection I did not see many ChangeL requests. 

--k1lZvvs/B4yU6o8G
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="simplify_dynamic_nn_negotation.diff"

dccp ccid-2: use new interface to refactor dynamic negotiation

Using the new function dccp_feat_get_nn_next_val(), this simplifies existing
code to not trigger a new negotiation if the requested new value equals the
old one.
---
 net/dccp/ccids/ccid2.c |   22 +++++-----------------
 net/dccp/feat.c        |    5 +++--
 2 files changed, 8 insertions(+), 19 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -815,10 +815,11 @@ int dccp_feat_signal_nn_change(struct so
 	    !dccp_feat_is_valid_nn_val(feat, nn_val))
 		return -EINVAL;
 
+	if (nn_val == dccp_feat_get_nn_next_val(sk, feat))
+		return 0;	/* already set or negotiation under way */
+
 	entry = dccp_feat_list_lookup(fn, feat, 1);
 	if (entry != NULL) {
-		if (entry->val.nn == fval.nn)
-			return 0;
 		dccp_pr_debug("Clobbering existing NN entry %llu -> %llu\n",
 			      (unsigned long long)entry->val.nn,
 			      (unsigned long long)nn_val);
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -102,27 +102,15 @@ static void ccid2_change_l_ack_ratio(str
 		DCCP_WARN("Limiting Ack Ratio (%u) to %u\n", val, max_ratio);
 		val = max_ratio;
 	}
-	if (val > DCCPF_ACK_RATIO_MAX)
-		val = DCCPF_ACK_RATIO_MAX;
-
-	if (val == ccid2_ack_ratio_next(sk))
-		return;
-
-	ccid2_pr_debug("changing local ack ratio to %u\n", val);
-	dccp_feat_signal_nn_change(sk, DCCPF_ACK_RATIO, val);
+	dccp_feat_signal_nn_change(sk, DCCPF_ACK_RATIO,
+				   min_t(u32, val, DCCPF_ACK_RATIO_MAX));
 }
 
 static void ccid2_change_l_seq_window(struct sock *sk, u64 val)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	if (val < DCCPF_SEQ_WMIN)
-		val = DCCPF_SEQ_WMIN;
-	if (val > DCCPF_SEQ_WMAX)
-		val = DCCPF_SEQ_WMAX;
-
-	if (val != dp->dccps_l_seq_win)
-		dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);
+	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW,
+				   clamp_val(val, DCCPF_SEQ_WMIN,
+						  DCCPF_SEQ_WMAX));
 }
 
 static void ccid2_hc_tx_rto_expire(unsigned long data)

--k1lZvvs/B4yU6o8G--
