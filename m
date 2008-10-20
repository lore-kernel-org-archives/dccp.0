From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 20 Oct 2008 15:43:00 +0000
Subject: [Announce]: Annoying build warning removed in CCID-3/-4 trees
Message-Id: <20081020154300.GA4153@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In the latest upload of the test tree I have removed the annoying build
warning that warned about a low HZ rate in the patch "dccp ccid-3: Bug
fix for the inter-packet scheduling algorithm".

As was suggested earlier thanks to Dave Miller, it is better to either
convert the code fully to hrtimers or not add such a warning.

The code has not been converted to hrtimers, it depends on available
time, but I send this message so that it can be added as a ToDo.

Here is the inter-diff of the tree (it has been mirrored in the CCID-4 tree also):

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -61,7 +61,6 @@
 # define TFRC_T_DELTA		   USEC_PER_MSEC
 #else
 # define TFRC_T_DELTA		   (USEC_PER_SEC / (2 * HZ))
-#warning Coarse CONFIG_HZ resolution -- higher value recommended for TFRC.
 #endif
 
 enum ccid3_options {
-- 
