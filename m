From: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
Date: Mon, 22 Nov 2021 10:16:20 +0000
Subject: [PATCH net-next 0/2] dccp/tcp: Minor fixes for inet_csk_listen_start().
Message-Id: <20211122101622.50572-1-kuniyu@amazon.co.jp>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The first patch removes an unused argument, and the second removes a stale
comment.


Kuniyuki Iwashima (2):
  dccp/tcp: Remove an unused argument in inet_csk_listen_start().
  dccp: Inline dccp_listen_start().

 include/net/inet_connection_sock.h            |  2 +-
 net/dccp/proto.c                              | 27 ++++++++-----------
 net/ipv4/af_inet.c                            |  2 +-
 net/ipv4/inet_connection_sock.c               |  2 +-
 .../bpf/progs/test_sk_storage_tracing.c       |  2 +-
 5 files changed, 15 insertions(+), 20 deletions(-)

-- 
2.30.2
