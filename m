From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 26 Nov 2006 03:19:10 +0000
Subject: [PATCH 4/4] [DCCP] ccid2: Allow window to grow larger
Message-Id: <20061126031909.GE17851@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Now that we can stuff bigger ack vectors into options.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid2.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index a97a899..ebd7949 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -35,7 +35,7 @@ struct ccid2_seq {
 	struct ccid2_seq	*ccid2s_next;
 };
 
-#define CCID2_SEQBUF_LEN 256
+#define CCID2_SEQBUF_LEN 1024
 #define CCID2_SEQBUF_MAX 128
 
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
-- 
1.4.2.1.g3d5c

