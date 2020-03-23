From: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
Date: Mon, 23 Mar 2020 18:18:12 +0000
Subject: [PATCH net-next 0/2] tcp/dccp: Cleanup initialisation code of refcounted.
Message-Id: <20200323181814.87661-1-kuniyu@amazon.co.jp>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

These patches cleanup initialisation of the refcounted which is passed to
__inet_lookup_skb().

Kuniyuki Iwashima (2):
  tcp/dccp: Move initialisation of refcounted into if block.
  tcp/dccp: Remove unnecessary initialization of refcounted.

 include/net/inet6_hashtables.h | 11 +++++++----
 include/net/inet_hashtables.h  | 11 +++++++----
 net/dccp/ipv4.c                |  1 -
 net/dccp/ipv6.c                |  1 -
 net/ipv4/tcp_ipv4.c            |  1 -
 net/ipv6/tcp_ipv6.c            |  1 -
 6 files changed, 14 insertions(+), 12 deletions(-)

-- 
2.17.2 (Apple Git-113)
