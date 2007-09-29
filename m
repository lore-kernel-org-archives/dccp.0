From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:39:53 +0000
Subject: [PATCH 12/13] [DCCP]: Correct documentation
Message-Id: <20070929153953.GQ23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This corrects erroneous documentation of the socket API.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 Documentation/networking/dccp.txt |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index fc8b4fa..afb66f9 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -55,12 +55,13 @@ be enabled at the receiver, too with suitable choice of CsCov.
 DCCP_SOCKOPT_SEND_CSCOV sets the sender checksum coverage. Values in the
 	range 0..15 are acceptable. The default setting is 0 (full coverage),
 	values between 1..15 indicate partial coverage.
-DCCP_SOCKOPT_SEND_CSCOV is for the receiver and has a different meaning: it
+DCCP_SOCKOPT_RECV_CSCOV is for the receiver and has a different meaning: it
 	sets a threshold, where again values 0..15 are acceptable. The default
 	of 0 means that all packets with a partial coverage will be discarded.
 	Values in the range 1..15 indicate that packets with minimally such a
 	coverage value are also acceptable. The higher the number, the more
-	restrictive this setting (see [RFC 4340, sec. 9.2.1]).
+	restrictive this setting (see [RFC 4340, sec. 9.2.1]). Partial coverage
+	settings are inherited to the child socket after accept().
 
 The following two options apply to CCID 3 exclusively and are getsockopt()-only.
 In either case, a TFRC info struct (defined in <linux/tfrc.h>) is returned.
-- 
1.5.2.2

