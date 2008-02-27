From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Feb 2008 14:23:04 +0000
Subject: [DCCP] [Patch 0/4]: Further CCID-2 clean-ups
Message-Id: <1204122188-9984-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Further CCID-2 work - 3 patches are clean-ups, removing unnecessary bits so
that the code becomes clearer. Patch #3 replaces the RTT estimator algorithm -
much work has gone into testing, and the TCP RTO estimator has been chosen -
not simply because it is easy to copy someone else's code, but because it
offers a much better solution, with evidence given.

Patch #1: After finding that the CCID-2 sanity tests are redundant,
          they are removed.
Patch #2: Simplifies decrementing the `pipe' variable in CCID-2, also
          removing redundancies.
Patch #3: Replaces the partly broken RTT estimator with a better
          alternative - reusing the TCP RTT estimator. 
Patch #4: Removes wrappers around sk_timer functions, since these
          do not add any further functionality / benefit. 


All patches have been uploaded - to the end - of the test tree at
	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[dccp]


PLEASE NOTE - there will be a server outage of this server from

	Friday 29th  Feb,   12:00 UTC until
	Monday 3rd   Mar, > 12:00 UTC

due to unavoidable brick and construction work in the building.
