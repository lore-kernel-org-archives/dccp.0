From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 3/9] [INFINIBAND] ipoib: Remove leftover use of neigh_ops->destructor
Message-Id: <11420257371843-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

b4692710ef01c342b050947b55240424854d272e
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index a2408d7..19fd173 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -115,7 +115,6 @@ static void ipoib_mcast_free(struct ipoi
 		if (neigh->ah)
 			ipoib_put_ah(neigh->ah);
 		*to_ipoib_neigh(neigh->neighbour) = NULL;
-		neigh->neighbour->ops->destructor = NULL;
 		kfree(neigh);
 	}
 
-- 
1.2.2.gd27d


