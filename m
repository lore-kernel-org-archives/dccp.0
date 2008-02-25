From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Feb 2008 09:52:00 +0000
Subject: [DCCP] [Patch v2 0/2] [Revision]: Fix Ack Vector MPS Minimum Value
Message-Id: <1203933122-27140-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a resubmission to fix a problem with accounting for Ack Vector
length in the MPS.

The present solution did not work well: the MPS did not account for Ack Vectors,
so that applications which relied on the MPS value via getopt were disadvantaged 
by having all their Ack Vectors put onto Syncs -- sorely degrading performance.

Found out by testing with gstreamer DCCP plugin.

Hence the revision of these two patches implements a new strategy -- it now
 * subtracts an estimated minimum from the MPS - 
   currently set to 16 bytes (found via experimentation) and
 * schedules a Sync only if the actual length is greater than
   this minimum _and_ there is no space left on the skb.

Patch #1: Is the revised version of the account-for-option-sizes-in-MPS patch.
Patch #2: Is the revised "exception handler" for overly large Ack Vectors.

Both patches have been uploaded to the test tree on
	git://eden-feed.erg.abnd.ac.uk/dccp_exp		[dccp]
