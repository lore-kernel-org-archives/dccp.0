From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 18 Mar 2011 11:30:52 +0000
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
Message-Id: <20110318113052.GA5508@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
List-Id: <dccp.vger.kernel.org>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
To: dccp@vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I have revised the patch set addressing the following comments of this thread:

 1) Renamed function to dccp_feat_nn_get().
 2) Added test to ensure that function is called for NN
    features back in.
 3) Replaced ccid2_ack_ratio_next() with calls to that
    function (dccp_feat_nn_get(sk, DCCPF_ACK_RATIO)).
 4) Replaced check for dccps_l_seq_win in ccid2_change_l_seq_window 
    with call to dccp_feat_nn_get(sk, DCCPF_SEQUENCE_WINDOW)
    (for similar calls see separate, attached patch).
 5) De-inlined ccid2_ack_ratio_next() wrapper as discussed.
 6) Updated remaining patches with regard to 1-4.
 
In (4) I created a separate patch. You mentioned earlier replacing references to
local seq_window with a call to the accessor function, these were the remaining
references, I noticed no regression.

This is all in the test tree, just uploaded 2.6.38
     git://eden-feed.erg.abdn.ac.uk/dccp_exp	[subtree 'dccp']

| > I don't know if blocking the Ack Ratio code is the reason, but during the
| > initial slow-start there were ChangeL requests for Sequence Window on nearly
| > every packet, which seems too much.
| 
| Right now, Change's are sent on every packet until the matching Confirm
| is received. That will be the cause of most of the Change's you are
| seeing.
| 
| The other thing is that at the beginning of a connection the sequence
| window will be reduced and then increased. The initial window of 100
| packets is too wide for 5*cwnd at the start of the connection. So the
| window will be reduced as low as it will go at the very beginning of the
| connection. However, as slow start picks up, cwnd will increase and the
| sequence window will as well.
| 
| I've seen the above behavior, but haven't thought of an effective
| solution (nor am I sure that we need a solution). Capping the minimum
| sequence window at the default (100 packets) would solve this, but that
| doesn't seem like a great solution.
| 
| > 
| > If low_threshold == high_threshold, it oscillates. I think you have already done
| > some work on this in the code using CCID2_WIN_CHANGE_FACTOR.
| 
| I'm not entirely certain what low_threshold and high_threshold you are
| talking about. I have not seen sequence window oscillations other as the
| congestion window oscillates in congestion avoidance as is expected.
|
I meant a Schmitt Trigger like behaviour:
 * low_threshold: to change from lower value to higher value 
 * hi_threshold:  to revert from higher value back to lower value
In these electronic devices there is a gap between low and hi, to avoid fluctuations.
Also audio effect gates have a similar setting.

With regard to your comment about the 100 packets at the begin, I was wondering if
the connection could not grossly exaggerate, or maybe even use the 100 packets.

But all that is not a big deal, stuff for fine-tuning the now much better ccid2 
engine. 

Thank you for all your good work. The comments helped a great deal too.

--cNdxnHkX5QqsyA0e
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="remaining_l_seq_win_refs.diff"

dccp ccid-2: replace remaining references to local Sequence Window value

This replaces the remaining references to dccps_l_seq_win with the corresponding
call to retrieve the current (STABLE if not in negotiation, CHANGING if being
negotiated) value of the feature-local sequence window.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -441,10 +441,10 @@ static void ccid2_new_ack(struct sock *s
 {
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
+	u64 l_seq_win = dccp_feat_nn_get(sk, DCCPF_SEQUENCE_WINDOW);
 	int r_seq_used = hc->tx_cwnd / dp->dccps_l_ack_ratio;
 
-	if (hc->tx_cwnd < dp->dccps_l_seq_win &&
-	    r_seq_used < dp->dccps_r_seq_win) {
+	if (hc->tx_cwnd < l_seq_win && r_seq_used < dp->dccps_r_seq_win) {
 		if (hc->tx_cwnd < hc->tx_ssthresh) {
 			if (*maxincr > 0 && ++hc->tx_packets_acked >= 2) {
 				hc->tx_cwnd += 1;
@@ -466,10 +466,10 @@ static void ccid2_new_ack(struct sock *s
 	else if (r_seq_used * CCID2_WIN_CHANGE_FACTOR < dp->dccps_r_seq_win/2)
 		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio / 2 ? : 1U);
 
-	if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR >= dp->dccps_l_seq_win)
-		ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win * 2);
-	else if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR < dp->dccps_l_seq_win/2)
-		ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win / 2);
+	if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR >= l_seq_win)
+		ccid2_change_l_seq_window(sk, l_seq_win * 2);
+	else if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR < l_seq_win / 2)
+		ccid2_change_l_seq_window(sk, l_seq_win / 2);
 
 	/*
 	 * FIXME: RTT is sampled several times per acknowledgment (for each

--cNdxnHkX5QqsyA0e--
