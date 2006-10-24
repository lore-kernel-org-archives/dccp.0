From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 14:00:06 +0000
Subject: [PATCH 9/17] [DCCP]: Add FIXME for tw_deschedule()
Message-Id: <200610241500.06901@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Add FIXME for tw_deschedule()

This just adds a FIXME for a function which is not implemented (maybe it
should be removed altogether, no code at all references it).

Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/dccp.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 8aa2697..f294b89 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -33,7 +33,7 @@ extern struct inet_hashinfo dccp_hashinf
 
 extern atomic_t dccp_orphan_count;
 extern int dccp_tw_count;
-extern void dccp_tw_deschedule(struct inet_timewait_sock *tw);
+extern void dccp_tw_deschedule(struct inet_timewait_sock *tw); /* FIXME: not implemented */
 
 extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 
