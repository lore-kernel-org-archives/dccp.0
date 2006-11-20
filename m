From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 20 Nov 2006 21:21:00 +0000
Subject: [PATCH 10/9] [DCCP]: Adds the tx buffer sysctls
Message-Id: <20061120212059.GK5246@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

David, this was a latecomer, its there together with the previous 9.

Best Regards,

- Arnaldo

This one got lost on the way from Ian to Gerrit to me, fix it.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 Documentation/networking/dccp.txt |    4 ++++
 include/linux/sysctl.h            |    1 +
 net/dccp/sysctl.c                 |    9 +++++++++
 3 files changed, 14 insertions(+)

------------------------------------------------------------------------------

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index 1910d09..dda1588 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -100,6 +100,10 @@ rx_ccid = 2
 seq_window = 100
 	The initial sequence window (sec. 7.5.2).
 
+tx_qlen = 5
+	The size of the transmit buffer in packets. A value of 0 corresponds
+	to an unbounded transmit buffer.
+
 Notes
 == 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 2e8c5ad..61dd99c 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -617,6 +617,7 @@ enum {
 	NET_DCCP_DEFAULT_REQ_RETRIES = 7,
 	NET_DCCP_DEFAULT_RETRIES1    = 8,
 	NET_DCCP_DEFAULT_RETRIES2    = 9,
+	NET_DCCP_DEFAULT_TX_QLEN     = 10,
 };
 
 /* /proc/sys/net/ipx */
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index 8b62061..4775ba3 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -91,6 +91,15 @@ static struct ctl_table dccp_default_tab
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_TX_QLEN,
+		.procname	= "tx_qlen",
+		.data		= &sysctl_dccp_tx_qlen,
+		.maxlen		= sizeof(sysctl_dccp_tx_qlen),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+
 	{ .ctl_name = 0, }
 };
 

