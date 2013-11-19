From: Wang Weidong <wangweidong1@huawei.com>
Date: Tue, 19 Nov 2013 02:47:25 +0000
Subject: [PATCH 0/2] ipv6: fix the missing copies when memcpy ipv6_pinfo
Message-Id: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch series include: add the helper function, use it when
memcpy struct ipv6_pinfo.

Wang Weidong (2):
  ipv6: add helper function for copy addrs from old sock
  ipv6: use sk_v6_copy_addrs when memcpy struct ipv6_pinfo

 include/net/sock.h  | 6 ++++++
 net/dccp/ipv6.c     | 4 ++++
 net/ipv6/tcp_ipv6.c | 4 ++++
 net/sctp/ipv6.c     | 4 ++++
 4 files changed, 18 insertions(+)

-- 
1.7.12


