From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Nov 2007 09:29:27 +0000
Subject: [PATCH 0/16]: Less is more - CCID3 patch set revised
Message-Id: <11952917831080-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This resubmission represents the same changeset as before, but with a
significant reduction in the number of patches: from 40 down to 16.

While an even smaller number of patches would be possible, this would
lump together unrelated changes, which should be avoided (ugly).

The set is line-by-line identical with the previous CCID3, apart from
two format differences detailed below.

Major changes:

 1. All `glue' patches have been removed, each patch solves an actual problem.

 2. All patch inter-dependencies have been completely removed:

    T h e   e n t i r e   t e s t   t r e e   i s   n o w   f u l l y   b i s e c t a b l e

    This has been exhaustively verified on three different architectures: doing
    a full module build (not just source compilation) for each single patch in
    the test tree. This passed in all cases.

The two changes are
 (a) I have added myself as MODULE_AUTHOR in ccids/lib/tfrc_module.c, so as to get
     emails about bugs (not that I believe/hope there are much, the code has been
     running allright for over 9 months now).

 (b) Another update with regard to Documentation/CodingStyle (in ccid3.c):

	-	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb))
	+	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb)) {
			/*
			 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
			 * has decreased (resp. p has increased), send feedback now.
			 */
			do_feedback = FBACK_PARAM_CHANGE;
	+	}

You can verify this by running a diff as follows:
	git-checkout -b old master
	curl http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/test-tree_2.6.24-rc2.diff.gz|gzip -d|patch -p1
	git-add net/dccp/ccids/lib/tfrc_module.c; git-commit -a -mold
	git-checkout -b new master
	git-pull git://eden-feed.erg.abdn.ac.uk/dccp_exp dccp
	git-diff old..new

I have updated the CCID4 patches to match this change also.

Ian, since you signed off every single of the 40 previous patches, I have kept
your Signed-off-by's for this resubmission, since it is effectively identical
with before.

--------------------------------- Detailed Patch listing -------------------------------------------------------------

Patch #1:  Rectifies incorrect use of MSS instead of `s' in the CCID3 code.
Patch #2:  Removes a code block which reports trivial/negligible amounts of Elapsed Time.
Patch #3:  Better detection of application-limited and idle periods.
Patch #4:  Inline for moving average (EWMA).

Patch #5:  Migrate & update TFRC TX history to singly-linked list.
Patch #6:  Remove old TFRC TX history infrastructure.

Patch #7:  Provide one file which holds the module build for dccp_tfrc_lib together.

Patch #9:  Reduce TFRC RX history to a small structure of only 4 entries (and that is sufficient).
Patch #10: Hook up new TFRC RX history with CCID3.
Patch #11: Remove old TFRC RX history infrastructure.

Patch #12: Introduce ringbuffer-based loss intervals database (which updates/completes many of the loss algorithms).
Patch #13: Interface new loss intervals database with CCID3.
Patch #14: Remove old loss interval tracking infrastructure.

Patch #15: Implement rfc3448bis changes to feedback reception (code used the old RFC 3448).
Patch #16: Implement rfc3448bis changes to nofeedback timer handling (code used the old RFC 3448).


As before, the entire changeset is fully documented on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/
