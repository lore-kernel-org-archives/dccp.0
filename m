From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 31 Jan 2008 18:31:40 +0000
Subject: [PATCH 2/6] [INET6]: Reorganize struct inet6_dev to save 8 bytes
Message-Id: <1201804304-28777-3-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

And make it a multiple of a 64 bytes, reducing cacheline trashing:

Before:

[acme@doppio net-2.6]$ pahole -C inet6_dev net/dccp/ipv6.o
struct inet6_dev {
	<SNIP>
	long unsigned int          mc_maxdelay;          /*    48     8 */
	unsigned char              mc_qrv;               /*    56     1 */
	unsigned char              mc_gq_running;        /*    57     1 */
	unsigned char              mc_ifc_count;         /*    58     1 */

	/* XXX 5 bytes hole, try to pack */

	/* --- cacheline 1 boundary (64 bytes) --- */
	struct timer_list          mc_gq_timer;          /*    64    48 */
	<SNIP>
	__u32                      if_flags;             /*   180     4 */
	int                        dead;                 /*   184     4 */
	u8                         rndid[8];             /*   188     8 */

	/* XXX 4 bytes hole, try to pack */

	/* --- cacheline 3 boundary (192 bytes) was 8 bytes ago --- */
	struct timer_list          regen_timer;          /*   200    48 */

	<SNIP>

	/* size: 456, cachelines: 8 */
	/* sum members: 447, holes: 2, sum holes: 9 */
	/* last cacheline: 8 bytes */
};

After:

[acme@doppio net-2.6]$ codiff net/dccp/ipv6.o.old net/dccp/ipv6.o
/home/acme/git/net-2.6/net/dccp/ipv6.c:
  struct inet6_dev |   -8
   1 struct changed

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/if_inet6.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b24508a..b0b882e 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -171,6 +171,7 @@ struct inet6_dev
 	unsigned char		mc_qrv;
 	unsigned char		mc_gq_running;
 	unsigned char		mc_ifc_count;
+	int			dead;
 	struct timer_list	mc_gq_timer;	/* general query timer */
 	struct timer_list	mc_ifc_timer;	/* interface change timer */
 
@@ -178,7 +179,6 @@ struct inet6_dev
 	rwlock_t		lock;
 	atomic_t		refcnt;
 	__u32			if_flags;
-	int			dead;
 
 #ifdef CONFIG_IPV6_PRIVACY
 	u8			rndid[8];
-- 
1.5.3.8

