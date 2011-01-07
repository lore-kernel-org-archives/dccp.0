From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 07 Jan 2011 11:35:30 +0000
Subject: [PATCH 3/3] dccp: make upper bound for seq_window consistent on 32/64 bit
Message-Id: <1294400130-5604-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The 'seq_window' sysctl sets the initial value for the DCCP Sequence Window,
which may range from 32..2^46-1 (RFC 4340, 7.5.2). The patch sets the upper
bound consistently to 2^32-1 on both 32 and 64 bit systems, which should be
sufficient - with a RTT of 1sec and 1-byte packets, a seq_window of 2^32-1
corresponds to a link speed of 34 Gbps.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    1 +
 net/dccp/sysctl.c                 |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -167,6 +167,7 @@ rx_ccid = 2
 seq_window = 100
 	The initial sequence window (sec. 7.5.2) of the sender. This influences
 	the local ackno validity and the remote seqno validity windows (7.5.1).
+	Values in the range Wmin = 32 (RFC 4340, 7.5.2) up to 2^32-1 can be set.
 
 tx_qlen = 5
 	The size of the transmit buffer in packets. A value of 0 corresponds
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -21,7 +21,8 @@
 /* Boundary values */
 static int		zero     = 0,
 			u8_max   = 0xFF;
-static unsigned long	seqw_min = 32;
+static unsigned long	seqw_min = DCCPF_SEQ_WMIN,
+			seqw_max = 0xFFFFFFFF;		/* maximum on 32 bit */
 
 static struct ctl_table dccp_default_table[] = {
 	{
@@ -31,6 +32,7 @@ static struct ctl_table dccp_default_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 		.extra1		= &seqw_min,		/* RFC 4340, 7.5.2 */
+		.extra2		= &seqw_max,
 	},
 	{
 		.procname	= "rx_ccid",
