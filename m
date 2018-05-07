From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 07 May 2018 18:43:33 +0000
Subject: [PATCH net-next v3 2/2] socket: keep track of the number of sockets allocated
Message-Id: <20180507184333.32688-3-sthemmin@microsoft.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Add a per-cpu counter to keep track of the number of inodes allocated
to sockets to fix incorrect statistics from ss command.

The ss command tries to keep track of the number of sockets
allocated but it was doing by the slabinfo statistics which are
wrong (due to merging) and not available when using slub.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/socket.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index f10f1d947c78..89ec7f41559d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -234,6 +234,18 @@ static int move_addr_to_user(struct sockaddr_storage *kaddr, int klen,
 }
 
 static struct kmem_cache *sock_inode_cachep __ro_after_init;
+static unsigned int __percpu *sock_pcpu_allocated;
+
+static unsigned int sock_allocated(void)
+{
+	unsigned int res = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		res += *per_cpu_ptr(sock_pcpu_allocated, cpu);
+
+	return res;
+}
 
 static struct inode *sock_alloc_inode(struct super_block *sb)
 {
@@ -248,6 +260,7 @@ static struct inode *sock_alloc_inode(struct super_block *sb)
 		kmem_cache_free(sock_inode_cachep, ei);
 		return NULL;
 	}
+	this_cpu_inc(*sock_pcpu_allocated);
 	init_waitqueue_head(&wq->wait);
 	wq->fasync_list = NULL;
 	wq->flags = 0;
@@ -270,6 +283,7 @@ static void sock_destroy_inode(struct inode *inode)
 	ei = container_of(inode, struct socket_alloc, vfs_inode);
 	wq = rcu_dereference_protected(ei->socket.wq, 1);
 	kfree_rcu(wq, rcu);
+	this_cpu_dec(*sock_pcpu_allocated);
 	kmem_cache_free(sock_inode_cachep, ei);
 }
 
@@ -290,6 +304,8 @@ static void init_inodecache(void)
 					       SLAB_MEM_SPREAD | SLAB_ACCOUNT),
 					      init_once);
 	BUG_ON(sock_inode_cachep = NULL);
+	sock_pcpu_allocated = alloc_percpu(unsigned int);
+	BUG_ON(sock_pcpu_allocated = NULL);
 }
 
 static const struct super_operations sockfs_ops = {
@@ -2738,8 +2754,9 @@ core_initcall(sock_init);	/* early initcall */
 #ifdef CONFIG_PROC_FS
 void socket_seq_show(struct seq_file *seq)
 {
-	seq_printf(seq, "sockets: used %d\n",
-		   sock_inuse_get(seq->private));
+	seq_printf(seq, "sockets: used %d allocated %u\n",
+		   sock_inuse_get(seq->private),
+		   sock_allocated());
 }
 #endif				/* CONFIG_PROC_FS */
 
-- 
2.17.0

