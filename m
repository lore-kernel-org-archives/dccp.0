From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:33 +0000
Subject: [PATCH 11/11] [DCCP]: Update documentation on ioctls
Message-Id: <1195658913-24840-12-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 Documentation/networking/dccp.txt |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index ffb9ca9..d76905a 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -136,6 +136,12 @@ sync_ratelimit = 125 ms
 	sequence-invalid packets on the same socket (RFC 4340, 7.5.4). The unit
 	of this parameter is milliseconds; a value of 0 disables rate-limiting.
 
+IOCTLS
+===
+FIONREAD
+	Works as in udp(7): returns in the `int' argument pointer the size of
+	the next pending datagram in bytes, or 0 when no datagram is pending.
+
 Notes
 == 
-- 
1.5.3.4

