From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:57:57 +0000
Subject: [PATCH 3/4][NEW]: Add documentation for socket options
Message-Id: <200701031357.57273@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Add documentation for socket options

This updates the documentation on CCID3-specific options.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -57,6 +57,16 @@ DCCP_SOCKOPT_SEND_CSCOV is for the recei
 	coverage value are also acceptable. The higher the number, the more
 	restrictive this setting (see [RFC 4340, sec. 9.2.1]).
 
+The following two options apply to CCID 3 exclusively and are getsockopt()-only.
+In either case, a TFRC info struct (defined in <linux/tfrc.h>) is returned.
+DCCP_SOCKOPT_CCID_RX_INFO
+	Returns a `struct tfrc_rx_info' in optval; the buffer for optval and
+	optlen must be set to at least sizeof(struct tfrc_rx_info).
+DCCP_SOCKOPT_CCID_TX_INFO
+	Returns a `struct tfrc_tx_info' in optval; the buffer for optval and
+	optlen must be set to at least sizeof(struct tfrc_tx_info).
+
+
 Sysctl variables
 ========
 Several DCCP default parameters can be managed by the following sysctls
