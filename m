From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:37:42 +0000
Subject: [PATCH 43/43]: Update API documentation
Message-Id: <200704051637.42217@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Update API documentation 

This adds documentation on the use of service codes on 
client and server.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -38,8 +38,10 @@ Socket options
 DCCP_SOCKOPT_SERVICE sets the service. The specification mandates use of
 service codes (RFC 4340, sec. 8.1.2); if this socket option is not set,
 the socket will fall back to 0 (which means that no meaningful service code
-is present). Connecting sockets set at most one service option; for
-listening sockets, multiple service codes can be specified.
+is present). On active sockets this is set before connect(); specifying more
+than one code has no effect (all subsequent service codes are ignored). The
+case is different for passive sockets, where multiple service codes (up to 32)
+can be set before calling bind().
 
 DCCP_SOCKOPT_GET_CUR_MPS is read-only and retrieves the current maximum packet
 size (application payload size) in bytes, see RFC 4340, section 14.
