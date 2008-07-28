From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jul 2008 18:13:56 +0000
Subject: [RFC/RFT] [PATCH 0/7] dccp: CCID-3 updates
Message-Id: <1217268843-19667-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This and the following changesets are updates for the CCID-3 code in the DCCP
test tree. They have been in my development tree for a while and seem to be
stable. Review and comments would be appreciated.

Purpose:
--------
 1. general updates;
 2. update the CCID-3 code to support ECN (this is not supported yet);
 3. update the CCID-3 code with regard to rfc3448bis-06, which is soon to
    become an RFC. This work is ongoing and takes time.

Patch #1: Checks if timer resolution is too coarse when loading the module and
          refuses to load when under the minimum resolution. This avoids
	  triggering bugs messages such as negative RTT samples.
Patch #2: Simplifies the CCID-3 TX state machine by using a Boolean flag.
Patch #3: Suppresses unavoidable "below resolution" warning for CCID-3 loss
          rate p (which decays towards 0, past the minimum resolution).
Patch #4: Modifies the TFRC initialisation routine to support early loss
          detection (the first-seen sequence number is set to GSR).
Patch #5: Adds early loss detection as enabled by patch #4. 
Patch #6: Simplifies updating the average TFRC loss interval I_mean. 
Patch #7: Replaces a lazy BUG_ON with a conditional. 


The test tree is available via

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		(subtree `dccp')

There is also a web view available.


CCID-4 Notes:
-------------
All changes have been ported to the CCID-4 tree as well and are on

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		(subtree `ccid4')

The following patches became obsolete as a result of this:	
	[CCID-3/4] Share TFRC sender states via tfrc_ccids
	[CCID-3/4] Share ccid3_tx_state_name function via tfrc_ccids
