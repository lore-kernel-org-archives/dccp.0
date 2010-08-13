From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Aug 2010 05:21:38 +0000
Subject: dccp test-tree [PATCH 0/3] ccid-2: Congestion Window Validation, TCP code sharing
Message-Id: <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a small set to enhance CCID-2, consisting mainly of Congestion Window
Validation (RFC 2681) ported over from TCP.

The first patch allows to make the TCP minimum RTO visible also to CCID-2. Since
CCID-3 also uses RTO (in the formula and for the nofeedback timer), I wonder
whether we should also do the same for CCID-3??

The changeset is:

  Patch #1: makes TCP's minimum-RTO code available to CCID-2
  Patch #2: simplifies the code by using an existing function
  Patch #3: implements CWV for CCID-2 -- largely taken from TCP

The patches have been dusted off from my development tree. They have been tested,
though it is some time ago. Hence I'd very much appreciate review and comments.

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree 'dccp']
