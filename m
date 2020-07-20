From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:14 +0000
Subject: [PATCH 01/24] bpfilter: reject kernel addresses
Message-Id: <20200720124737.118617-2-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When feeding addresses to userspace we can't support kernel addresses
that were fed under set_fs(KERNEL_DS) from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/bpfilter/bpfilter_kern.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
index 2c31e82cb953af..977e9dad72ca4f 100644
--- a/net/bpfilter/bpfilter_kern.c
+++ b/net/bpfilter/bpfilter_kern.c
@@ -41,6 +41,11 @@ static int __bpfilter_process_sockopt(struct sock *sk, int optname,
 	ssize_t n;
 	int ret = -EFAULT;
 
+	if (uaccess_kernel()) {
+		pr_err("kernel access not supported\n");
+		return -EFAULT;
+	}
+
 	req.is_set = is_set;
 	req.pid = current->pid;
 	req.cmd = optname;
-- 
2.27.0
