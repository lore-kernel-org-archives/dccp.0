From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 08 Jan 2008 14:07:53 +0000
Subject: [DCCP] [PATCH 0/3]: Finishing Ack Vector patch set
Message-Id: <1199801276-16955-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the "new stuff" for Ack Vectors, completing the Ack Vector work.

All other patches are as before, with the single exception of the update sent
yesterday (the recovery strategy for dealing with suddenly large losses).

Arnaldo, can you please indicate whether I should resubmit the older patches.

After some more testing I am positive that these are now ready to be considered.

Patch #1: Addresses the pending FIXME, if Ack Vectors grow too large for a packet,
          their variable-length information is transported via a separate/scheduled
	  Sync. This mechanism can also be used for other out-of-band signalling
	  (e.g. slow-receiver option).

Patch #2: Since there is already a rich option-parsing infrastructure in options.c,
          it is not necessary to replicate the code to parse Ack Vectors. This patch
	  adds utility routines to store parsed Ack Vectors, which are processed by
	  the existing infrastructure via the hc_tx_parse_options() interface.

Patch #3: Integrates patch #3 for use with CCID2.	  

All patches have been uploaded to git://eden-feed.erg.abdn.ac.uk/dccp_exp
