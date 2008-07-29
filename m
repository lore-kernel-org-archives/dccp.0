From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 10:05:45 +0000
Subject: [RFC/RFT] [PATCH 0/7] dccp ccid-3: Further updates (second set)
Message-Id: <1217325952-12337-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This second patch set continues the work on CCID-3, to update with regard to
rfc3448bis, and to prepare for ECN support. Review and comments are welcome.

Patch #1: Migrates sampling of `s' and counting received bytes into tfrc_lib.
Patch #2: Removes redundant RX states.
Patch #3: Continued RTT sampling and migration of RTT sampling into tfrc_lib.
Patch #4: Isolates the min/max clamping functionality from dccp_sample_rtt().
Patch #5: Optimises the RTT sampling algorithm to increase number of samples.
Patch #6: Updates computation of X_recv following changes to RFC 4342. 
Patch #7: Makes rx_handle_loss() the main point for dealing with congestion.


The now-updated test tree is available via

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		(subtree `dccp')

There is also a web view available.


CCID-4 Notes:
-------------
All changes have been ported to the CCID-4 tree as well and are on

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		(subtree `ccid4')

The following patches became obsolete as a result of this:	
	[CCID-3/4] Share TFRC receiver states via tfrc_ccids
	[CCID-3/4] Share ccid3_rx_state_name function via tfrc_ccids
