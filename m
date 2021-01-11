From: Jakub Kicinski <kuba@kernel.org>
Date: Mon, 11 Jan 2021 05:27:58 +0000
Subject: [PATCH net 8/9] MAINTAINERS: dccp: move Gerrit Renker to CREDITS
Message-Id: <20210111052759.2144758-9-kuba@kernel.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As far as I can tell we haven't heard from Gerrit for roughly
5 years now. DCCP patch would really benefit from some review.
Gerrit was the last maintainer so mark this entry as orphaned.

Subsystem DCCP PROTOCOL
  Changes 38 / 166 (22%)
  (No activity)
  Top reviewers:
    [6]: kstewart@linuxfoundation.org
    [6]: allison@lohutok.net
    [5]: edumazet@google.com
  INACTIVE MAINTAINER Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Jakub Kicinski <kuba@kernel.org>
---
CC: Gerrit Renker <gerrit@erg.abdn.ac.uk>
CC: dccp@vger.kernel.org
---
 CREDITS     | 4 ++++
 MAINTAINERS | 3 +--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/CREDITS b/CREDITS
index ce8eae8c5aa4..9add7e6a4fa0 100644
--- a/CREDITS
+++ b/CREDITS
@@ -1288,6 +1288,10 @@ D: Major kbuild rework during the 2.5 cycle
 D: ISDN Maintainer
 S: USA
 
+N: Gerrit Renker
+E: gerrit@erg.abdn.ac.uk
+D: DCCP protocol support.
+
 N: Philip Gladstone
 E: philip@gladstonefamily.net
 D: Kernel / timekeeping stuff
diff --git a/MAINTAINERS b/MAINTAINERS
index a5d69857f85a..17736ec96ec4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4920,9 +4920,8 @@ F:	Documentation/scsi/dc395x.rst
 F:	drivers/scsi/dc395x.*
 
 DCCP PROTOCOL
-M:	Gerrit Renker <gerrit@erg.abdn.ac.uk>
 L:	dccp@vger.kernel.org
-S:	Maintained
+S:	Orphan
 W:	http://www.linuxfoundation.org/collaborate/workgroups/networking/dccp
 F:	include/linux/dccp.h
 F:	include/linux/tfrc.h
-- 
2.26.2
