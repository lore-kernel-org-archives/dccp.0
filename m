From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 11 Mar 2011 11:30:42 +0000
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
Message-Id: <20110311113042.GB4876@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| I now had a chance to put this patch through extensive tests. I had to
| modify two things about the patch to get good performance:
| 1) [...] The primary change is adding a function called
|     dccp_feat_get_nn_next_val() to feat.c.
Well done, this looks good. I did some minor editing:
 * whitespace/formatting/comments,
 * simplification/subsumption,
 * function should not be called for non-NN or non-known
   feature, hence turned that into a DCCP_BUG() condition.

| 2)In a situation where the ack ratio has to be reduced because of an
|    RTO, idle period, or loss, CCID-2 now sets the ack ratio to half of the
|    congestion window (or 1 if that's zero) instead of to the congestion
|    window. This should reduce the problems if one ack is lost (we have to
|    lose two acks to not acknowledge an entire congestion window and trigg=
er
|    RTO)
|=20
I think this makes for a separate patch, and it would be good to commentify
the above into the code; please also see 3(b) below.

| Below is an improved patch. What are your thoughts on these changes?
|=20
I have uploaded your version of the patch to the test tree,=20

http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h=126ba220483bb990cf2c4b625464c89909583d3c

Some work still remains to be done:

 1) Since ccid2_ack_ratio_next(sk) is just a wrapper around
    dccp_feat_get_nn_next_val(sk, DCCPF_ACK_RATIO), ok to
    use this instead?
 2) Analogously, for the local sequence window feature the
    dccp_feat_get_nn_next_val() is not used, it uses the
    current value:
    if (val !=3D dp->dccps_l_seq_win)
	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);
 3) There is room for some refactoring:
    a) dccp_feat_signal_nn_change() always implies also in part
       dccp_feat_get_nn_next_val(): if the latter function returns
       the same value as the supposedly 'new' one, it is not
       necessary to start a new negotiation. So all the repeated
       tests could be folded into that function.
    b) The following pattern appears three times in ccid2.c:
	if (ccid2_ack_ratio_next(sk) > hc->tx_cwnd)
		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
       Perhaps this can, as some other parts of this patch set, be
       refactored (e.g. the CCID-2 part is already a separate patch).

Other than the minor edits I have left your patch as is, i.e. I have
not yet performed changes (1) and (2), awaiting your opinion on that.

Once you are ok with the edits, I will add your Signed-off-by.
