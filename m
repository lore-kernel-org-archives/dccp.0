From: Kuniyuki Iwashima <kuniyu@amazon.com>
Date: Wed, 16 Nov 2022 22:28:03 +0000
Subject: [PATCH v2 net 2/4] dccp/tcp: Remove NULL check for prev_saddr in inet_bhash2_update_saddr().
Message-Id: <20221116222805.64734-3-kuniyu@amazon.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When we call inet_bhash2_update_saddr(), prev_saddr is always non-NULL.
Let's remove the unnecessary test.

Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
---
 net/ipv4/inet_hashtables.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 033bf3c2538f..d745f962745e 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -877,13 +877,10 @@ int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct soc
 
 	head2 = inet_bhashfn_portaddr(hinfo, sk, net, port);
 
-	if (prev_saddr) {
-		spin_lock_bh(&prev_saddr->lock);
-		__sk_del_bind2_node(sk);
-		inet_bind2_bucket_destroy(hinfo->bind2_bucket_cachep,
-					  inet_csk(sk)->icsk_bind2_hash);
-		spin_unlock_bh(&prev_saddr->lock);
-	}
+	spin_lock_bh(&prev_saddr->lock);
+	__sk_del_bind2_node(sk);
+	inet_bind2_bucket_destroy(hinfo->bind2_bucket_cachep, inet_csk(sk)->icsk_bind2_hash);
+	spin_unlock_bh(&prev_saddr->lock);
 
 	spin_lock_bh(&head2->lock);
 	tb2 = inet_bind2_bucket_find(head2, net, port, l3mdev, sk);
-- 
2.30.2
