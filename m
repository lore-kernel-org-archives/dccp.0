From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Nov 2006 15:28:34 +0000
Subject: [PATCH 5/10][DCCP] timewait: Remove leftover extern declarations
Message-Id: <20061110152834.GI23311@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker noticed dccp_tw_deschedule and submitted a patch with a FIXME,
but as he suggests in the same patch the best thing is to just ditch this
declaration, while doing that also noticed that tcp_tw_count is as well not
defined anywhere, so ditch it too.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 dccp.h |    2 --
 1 file changed, 2 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 9f00dd8..8964b18 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -35,8 +35,6 @@ #endif
 extern struct inet_hashinfo dccp_hashinfo;
 
 extern atomic_t dccp_orphan_count;
-extern int dccp_tw_count;
-extern void dccp_tw_deschedule(struct inet_timewait_sock *tw);
 
 extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 
