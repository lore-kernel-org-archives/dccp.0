From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Wed, 06 May 2020 12:54:57 +0000
Subject: [PATCH bpf-next 01/17] flow_dissector: Extract attach/detach/query helpers
Message-Id: <20200506125514.1020829-2-jakub@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Move generic parts of callbacks for querying, attaching, and detaching a
single BPF program for reuse by other BPF program types.

Subsequent patch makes use of the extracted routines.

Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
---
 include/linux/bpf.h       |  8 +++++
 net/core/filter.c         | 68 +++++++++++++++++++++++++++++++++++++++
 net/core/flow_dissector.c | 61 +++++++----------------------------
 3 files changed, 88 insertions(+), 49 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1262ec460ab3..716c47ac1e75 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -31,6 +31,7 @@ struct seq_file;
 struct btf;
 struct btf_type;
 struct exception_table_entry;
+struct mutex;
 
 extern struct idr btf_idr;
 extern spinlock_t btf_idr_lock;
@@ -1660,4 +1661,11 @@ enum bpf_text_poke_type {
 int bpf_arch_text_poke(void *ip, enum bpf_text_poke_type t,
 		       void *addr1, void *addr2);
 
+int bpf_prog_query_one(struct bpf_prog __rcu **pprog,
+		       const union bpf_attr *attr,
+		       union bpf_attr __user *uattr);
+int bpf_prog_attach_one(struct bpf_prog __rcu **pprog, struct mutex *lock,
+			struct bpf_prog *prog, u32 flags);
+int bpf_prog_detach_one(struct bpf_prog __rcu **pprog, struct mutex *lock);
+
 #endif /* _LINUX_BPF_H */
diff --git a/net/core/filter.c b/net/core/filter.c
index dfaf5df13722..bc25bb1085b1 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -8740,6 +8740,74 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 	return ret;
 }
 
+int bpf_prog_query_one(struct bpf_prog __rcu **pprog,
+		       const union bpf_attr *attr,
+		       union bpf_attr __user *uattr)
+{
+	__u32 __user *prog_ids = u64_to_user_ptr(attr->query.prog_ids);
+	u32 prog_id, prog_cnt = 0, flags = 0;
+	struct bpf_prog *attached;
+
+	if (attr->query.query_flags)
+		return -EINVAL;
+
+	rcu_read_lock();
+	attached = rcu_dereference(*pprog);
+	if (attached) {
+		prog_cnt = 1;
+		prog_id = attached->aux->id;
+	}
+	rcu_read_unlock();
+
+	if (copy_to_user(&uattr->query.attach_flags, &flags, sizeof(flags)))
+		return -EFAULT;
+	if (copy_to_user(&uattr->query.prog_cnt, &prog_cnt, sizeof(prog_cnt)))
+		return -EFAULT;
+
+	if (!attr->query.prog_cnt || !prog_ids || !prog_cnt)
+		return 0;
+
+	if (copy_to_user(prog_ids, &prog_id, sizeof(u32)))
+		return -EFAULT;
+
+	return 0;
+}
+
+int bpf_prog_attach_one(struct bpf_prog __rcu **pprog, struct mutex *lock,
+			struct bpf_prog *prog, u32 flags)
+{
+	struct bpf_prog *attached;
+
+	if (flags)
+		return -EINVAL;
+
+	attached = rcu_dereference_protected(*pprog,
+					     lockdep_is_held(lock));
+	if (attached = prog) {
+		/* The same program cannot be attached twice */
+		return -EINVAL;
+	}
+	rcu_assign_pointer(*pprog, prog);
+	if (attached)
+		bpf_prog_put(attached);
+
+	return 0;
+}
+
+int bpf_prog_detach_one(struct bpf_prog __rcu **pprog, struct mutex *lock)
+{
+	struct bpf_prog *attached;
+
+	attached = rcu_dereference_protected(*pprog,
+					     lockdep_is_held(lock));
+	if (!attached)
+		return -ENOENT;
+	RCU_INIT_POINTER(*pprog, NULL);
+	bpf_prog_put(attached);
+
+	return 0;
+}
+
 #ifdef CONFIG_INET
 static void bpf_init_reuseport_kern(struct sk_reuseport_kern *reuse_kern,
 				    struct sock_reuseport *reuse,
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 3eff84824c8b..5ff99ed175bd 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -73,46 +73,22 @@ EXPORT_SYMBOL(skb_flow_dissector_init);
 int skb_flow_dissector_prog_query(const union bpf_attr *attr,
 				  union bpf_attr __user *uattr)
 {
-	__u32 __user *prog_ids = u64_to_user_ptr(attr->query.prog_ids);
-	u32 prog_id, prog_cnt = 0, flags = 0;
-	struct bpf_prog *attached;
 	struct net *net;
-
-	if (attr->query.query_flags)
-		return -EINVAL;
+	int ret;
 
 	net = get_net_ns_by_fd(attr->query.target_fd);
 	if (IS_ERR(net))
 		return PTR_ERR(net);
 
-	rcu_read_lock();
-	attached = rcu_dereference(net->flow_dissector_prog);
-	if (attached) {
-		prog_cnt = 1;
-		prog_id = attached->aux->id;
-	}
-	rcu_read_unlock();
+	ret = bpf_prog_query_one(&net->flow_dissector_prog, attr, uattr);
 
 	put_net(net);
-
-	if (copy_to_user(&uattr->query.attach_flags, &flags, sizeof(flags)))
-		return -EFAULT;
-	if (copy_to_user(&uattr->query.prog_cnt, &prog_cnt, sizeof(prog_cnt)))
-		return -EFAULT;
-
-	if (!attr->query.prog_cnt || !prog_ids || !prog_cnt)
-		return 0;
-
-	if (copy_to_user(prog_ids, &prog_id, sizeof(u32)))
-		return -EFAULT;
-
-	return 0;
+	return ret;
 }
 
 int skb_flow_dissector_bpf_prog_attach(const union bpf_attr *attr,
 				       struct bpf_prog *prog)
 {
-	struct bpf_prog *attached;
 	struct net *net;
 	int ret = 0;
 
@@ -145,16 +121,9 @@ int skb_flow_dissector_bpf_prog_attach(const union bpf_attr *attr,
 		}
 	}
 
-	attached = rcu_dereference_protected(net->flow_dissector_prog,
-					     lockdep_is_held(&flow_dissector_mutex));
-	if (attached = prog) {
-		/* The same program cannot be attached twice */
-		ret = -EINVAL;
-		goto out;
-	}
-	rcu_assign_pointer(net->flow_dissector_prog, prog);
-	if (attached)
-		bpf_prog_put(attached);
+	ret = bpf_prog_attach_one(&net->flow_dissector_prog,
+				  &flow_dissector_mutex, prog,
+				  attr->attach_flags);
 out:
 	mutex_unlock(&flow_dissector_mutex);
 	return ret;
@@ -162,21 +131,15 @@ int skb_flow_dissector_bpf_prog_attach(const union bpf_attr *attr,
 
 int skb_flow_dissector_bpf_prog_detach(const union bpf_attr *attr)
 {
-	struct bpf_prog *attached;
-	struct net *net;
+	struct net *net = current->nsproxy->net_ns;
+	int ret;
 
-	net = current->nsproxy->net_ns;
 	mutex_lock(&flow_dissector_mutex);
-	attached = rcu_dereference_protected(net->flow_dissector_prog,
-					     lockdep_is_held(&flow_dissector_mutex));
-	if (!attached) {
-		mutex_unlock(&flow_dissector_mutex);
-		return -ENOENT;
-	}
-	RCU_INIT_POINTER(net->flow_dissector_prog, NULL);
-	bpf_prog_put(attached);
+	ret =  bpf_prog_detach_one(&net->flow_dissector_prog,
+				   &flow_dissector_mutex);
 	mutex_unlock(&flow_dissector_mutex);
-	return 0;
+
+	return ret;
 }
 
 /**
-- 
2.25.3
