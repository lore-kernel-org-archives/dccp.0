From: Christoph Hellwig <hch@lst.de>
Date: Thu, 23 Jul 2020 06:08:45 +0000
Subject: [PATCH 03/26] bpfilter: reject kernel addresses
Message-Id: <20200723060908.50081-4-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The bpfilter user mode helper processes the optval address using
process_vm_readv.  Don't send it kernel addresses fed under
set_fs(KERNEL_DS) as that won't work.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/bpfilter/bpfilter_kern.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
index 78d561f2c54da7..00540457e5f4d3 100644
--- a/net/bpfilter/bpfilter_kern.c
+++ b/net/bpfilter/bpfilter_kern.c
@@ -70,6 +70,10 @@ static int bpfilter_process_sockopt(struct sock *sk, int optname,
 		.addr		= (uintptr_t)optval,
 		.len		= optlen,
 	};
+	if (uaccess_kernel()) {
+		pr_err("kernel access not supported\n");
+		return -EFAULT;
+	}
 	return bpfilter_send_req(&req);
 }
 
-- 
2.27.0
