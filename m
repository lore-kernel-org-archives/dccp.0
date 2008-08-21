From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Aug 2008 17:19:45 +0000
Subject: [RFC/RFT] [PATCH 0/3] dccp: Updates for parsing header options
Message-Id: <1219339188-31873-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an update of the test tree with regard to parsing DCCP header options.

Patch #1: Changes the policy to silently ignore header options with nonsensical
          lengths, as specified in RFC 4340, 5.8.
Patch #2: Fills in the Data1...3 fields as required for "Option Error" Resets.
Patch #3: Is a reworked version of an existing test tree patch which has been
          fixed to return the (hopefully) correct Reset code in each error case.


The set has been compile-tested and updates (-rc4) have been uploaded to

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']

Review and comments are welcome.

