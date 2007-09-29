From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:38:27 +0000
Subject: [PATCH 04/13] [DCCP]: Update API documentation
Message-Id: <20070929153827.GI23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds documentation on the use of service codes on
client and server.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 Documentation/networking/dccp.txt |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index f915718..fc8b4fa 100644
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
@@ -124,5 +126,5 @@ Notes
 == 
 DCCP does not travel through NAT successfully at present on many boxes. This is
-because the checksum covers the psuedo-header as per TCP and UDP. Linux NAT
+because the checksum covers the pseudo-header as per TCP and UDP. Linux NAT
 support for DCCP has been added.
-- 
1.5.2.2

