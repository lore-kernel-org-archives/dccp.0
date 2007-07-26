From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Thu, 26 Jul 2007 22:39:37 +0000
Subject: [PATCH][dccp] Fix memory leak and clean up style - dccp_feat_empty_confirm()
Message-Id: <200707270039.37860.jesper.juhl@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Greetings,

There's a memory leak in net/dccp/feat.c::dccp_feat_empty_confirm().
If we hit the 'default:' case of the 'switch' statement, then we 
return without freeing 'opt', thus leaking 'struct dccp_opt_pend' 
bytes.
The leak is fixed easily enough by adding a kfree(opt); before the 
return statement.
The patch also changes the layout of the 'switch' to be more in line 
with CodingStyle.

Patch has been compile tested.

Please consider merging.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 net/dccp/feat.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index cd845df..5ebdd86 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -327,10 +327,16 @@ static void dccp_feat_empty_confirm(struct dccp_minisock *dmsk,
 	}
 
 	switch (type) {
-	case DCCPO_CHANGE_L: opt->dccpop_type = DCCPO_CONFIRM_R; break;
-	case DCCPO_CHANGE_R: opt->dccpop_type = DCCPO_CONFIRM_L; break;
-	default:	     DCCP_WARN("invalid type %d\n", type); return;
-
+	case DCCPO_CHANGE_L:
+		opt->dccpop_type = DCCPO_CONFIRM_R;
+		break;
+	case DCCPO_CHANGE_R:
+		opt->dccpop_type = DCCPO_CONFIRM_L;
+		break;
+	default:
+		DCCP_WARN("invalid type %d\n", type);
+		kfree(opt);
+		return;
 	}
 	opt->dccpop_feat = feature;
 	opt->dccpop_val	 = NULL;





PS. Please keep me on Cc when replying.


