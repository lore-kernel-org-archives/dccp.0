From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 13 Aug 2008 12:55:32 +0000
Subject: [PATCH] dccp: change L/R must have at least one byte in the
Message-Id: <20080813125532.GD12888@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David, Gerrit,

	Please consider applying.

- Arnaldo

dccp: change L/R must have at least one byte in the dccpsf_val field
    
Thanks to Eugene Teo for reporting this problem.
    
Signed-off-by: Eugene Teo <eugenete@kernel.sg>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index b622d97..1ca3b26 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -474,6 +474,11 @@ static int dccp_setsockopt_change(struct sock *sk, int type,
 
 	if (copy_from_user(&opt, optval, sizeof(opt)))
 		return -EFAULT;
+	/*
+	 * rfc4340: 6.1. Change Options
+	 */
+	if (opt.dccpsf_len < 1)
+		return -EINVAL;
 
 	val = kmalloc(opt.dccpsf_len, GFP_KERNEL);
 	if (!val)



