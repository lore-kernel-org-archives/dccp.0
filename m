From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 31 Jan 2008 18:31:42 +0000
Subject: [PATCH 4/6] [IPV6]: Reorganize strut ipv6_mc_socklist to save 8 bytes
Message-Id: <1201804304-28777-5-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

/home/acme/git/net-2.6/net/dccp/ipv6.c:
  struct ipv6_mc_socklist |   -8
 1 struct changed

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/if_inet6.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b0b882e..b2509d4 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -82,9 +82,9 @@ struct ipv6_mc_socklist
 {
 	struct in6_addr		addr;
 	int			ifindex;
+	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
 	struct ipv6_mc_socklist *next;
 	rwlock_t		sflock;
-	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
 	struct ip6_sf_socklist	*sflist;
 };
 
-- 
1.5.3.8

