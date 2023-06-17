From: David Howells <dhowells@redhat.com>
Date: Sat, 17 Jun 2023 12:11:46 +0000
Subject: [PATCH net-next v2 17/17] net: Kill MSG_SENDPAGE_NOTLAST
Message-Id: <20230617121146.716077-18-dhowells@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Now that ->sendpage() has been removed, MSG_SENDPAGE_NOTLAST can be cleaned
up.  Things were converted to use MSG_MORE instead, but the protocol
sendpage stubs still convert MSG_SENDPAGE_NOTLAST to MSG_MORE, which is now
unnecessary.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: "David S. Miller" <davem@davemloft.net>
cc: Eric Dumazet <edumazet@google.com>
cc: Jakub Kicinski <kuba@kernel.org>
cc: Paolo Abeni <pabeni@redhat.com>
cc: Jens Axboe <axboe@kernel.dk>
cc: Matthew Wilcox <willy@infradead.org>
cc: bpf@vger.kernel.org
cc: dccp@vger.kernel.org
cc: linux-afs@lists.infradead.org
cc: linux-arm-msm@vger.kernel.org
cc: linux-can@vger.kernel.org
cc: linux-crypto@vger.kernel.org
cc: linux-doc@vger.kernel.org
cc: linux-hams@vger.kernel.org
cc: linux-perf-users@vger.kernel.org
cc: linux-rdma@vger.kernel.org
cc: linux-sctp@vger.kernel.org
cc: linux-wpan@vger.kernel.org
cc: linux-x25@vger.kernel.org
cc: mptcp@lists.linux.dev
cc: netdev@vger.kernel.org
cc: rds-devel@oss.oracle.com
cc: tipc-discussion@lists.sourceforge.net
cc: virtualization@lists.linux-foundation.org
---
 include/linux/socket.h                         | 4 +---
 net/ipv4/tcp_bpf.c                             | 4 +++-
 net/tls/tls_device.c                           | 3 +--
 net/tls/tls_main.c                             | 2 +-
 net/tls/tls_sw.c                               | 2 +-
 tools/perf/trace/beauty/include/linux/socket.h | 1 -
 tools/perf/trace/beauty/msg_flags.c            | 3 ---
 7 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 58204700018a..39b74d83c7c4 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -319,7 +319,6 @@ struct ucred {
 #define MSG_MORE	0x8000	/* Sender will send more */
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 #define MSG_SENDPAGE_NOPOLICY 0x10000 /* sendpage() internal : do no apply policy */
-#define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
 #define MSG_BATCH	0x40000 /* sendmmsg(): more messages coming */
 #define MSG_EOF         MSG_FIN
 #define MSG_NO_SHARED_FRAGS 0x80000 /* sendpage() internal : page frags are not shared */
@@ -341,8 +340,7 @@ struct ucred {
 
 /* Flags to be cleared on entry by sendmsg and sendmmsg syscalls */
 #define MSG_INTERNAL_SENDMSG_FLAGS \
-	(MSG_SPLICE_PAGES | MSG_SENDPAGE_NOPOLICY | MSG_SENDPAGE_NOTLAST | \
-	 MSG_SENDPAGE_DECRYPTED)
+	(MSG_SPLICE_PAGES | MSG_SENDPAGE_NOPOLICY | MSG_SENDPAGE_DECRYPTED)
 
 /* Setsockoptions(2) level. Thanks to BSD these must match IPPROTO_xxx */
 #define SOL_IP		0
diff --git a/net/ipv4/tcp_bpf.c b/net/ipv4/tcp_bpf.c
index 870c1cde4010..8f535e436ea3 100644
--- a/net/ipv4/tcp_bpf.c
+++ b/net/ipv4/tcp_bpf.c
@@ -90,7 +90,9 @@ static int tcp_bpf_push(struct sock *sk, struct sk_msg *msg, u32 apply_bytes,
 {
 	bool apply = apply_bytes;
 	struct scatterlist *sge;
-	struct msghdr msghdr = { .msg_flags = flags | MSG_SPLICE_PAGES, };
+	struct msghdr msghdr = {
+		.msg_flags = flags | MSG_SPLICE_PAGES | MSG_MORE,
+	};
 	struct page *page;
 	int size, ret = 0;
 	u32 off;
diff --git a/net/tls/tls_device.c b/net/tls/tls_device.c
index 840ee06f1708..2021fe557e50 100644
--- a/net/tls/tls_device.c
+++ b/net/tls/tls_device.c
@@ -441,8 +441,7 @@ static int tls_push_data(struct sock *sk,
 	long timeo;
 
 	if (flags &
-	    ~(MSG_MORE | MSG_DONTWAIT | MSG_NOSIGNAL | MSG_SENDPAGE_NOTLAST |
-	      MSG_SPLICE_PAGES))
+	    ~(MSG_MORE | MSG_DONTWAIT | MSG_NOSIGNAL | MSG_SPLICE_PAGES))
 		return -EOPNOTSUPP;
 
 	if (unlikely(sk->sk_err))
diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index d5ed4d47b16e..b6896126bb92 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -127,7 +127,7 @@ int tls_push_sg(struct sock *sk,
 {
 	struct bio_vec bvec;
 	struct msghdr msg = {
-		.msg_flags = MSG_SENDPAGE_NOTLAST | MSG_SPLICE_PAGES | flags,
+		.msg_flags = MSG_SPLICE_PAGES | flags,
 	};
 	int ret = 0;
 	struct page *p;
diff --git a/net/tls/tls_sw.c b/net/tls/tls_sw.c
index 9b3aa89a4292..53f944e6d8ef 100644
--- a/net/tls/tls_sw.c
+++ b/net/tls/tls_sw.c
@@ -1194,7 +1194,7 @@ int tls_sw_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 	if (msg->msg_flags & ~(MSG_MORE | MSG_DONTWAIT | MSG_NOSIGNAL |
 			       MSG_CMSG_COMPAT | MSG_SPLICE_PAGES |
-			       MSG_SENDPAGE_NOTLAST | MSG_SENDPAGE_NOPOLICY))
+			       MSG_SENDPAGE_NOPOLICY))
 		return -EOPNOTSUPP;
 
 	ret = mutex_lock_interruptible(&tls_ctx->tx_lock);
diff --git a/tools/perf/trace/beauty/include/linux/socket.h b/tools/perf/trace/beauty/include/linux/socket.h
index 13c3a237b9c9..3bef212a24d7 100644
--- a/tools/perf/trace/beauty/include/linux/socket.h
+++ b/tools/perf/trace/beauty/include/linux/socket.h
@@ -318,7 +318,6 @@ struct ucred {
 #define MSG_MORE	0x8000	/* Sender will send more */
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 #define MSG_SENDPAGE_NOPOLICY 0x10000 /* sendpage() internal : do no apply policy */
-#define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
 #define MSG_BATCH	0x40000 /* sendmmsg(): more messages coming */
 #define MSG_EOF         MSG_FIN
 #define MSG_NO_SHARED_FRAGS 0x80000 /* sendpage() internal : page frags are not shared */
diff --git a/tools/perf/trace/beauty/msg_flags.c b/tools/perf/trace/beauty/msg_flags.c
index ea68db08b8e7..b5b580e5a77e 100644
--- a/tools/perf/trace/beauty/msg_flags.c
+++ b/tools/perf/trace/beauty/msg_flags.c
@@ -8,9 +8,6 @@
 #ifndef MSG_WAITFORONE
 #define MSG_WAITFORONE		   0x10000
 #endif
-#ifndef MSG_SENDPAGE_NOTLAST
-#define MSG_SENDPAGE_NOTLAST	   0x20000
-#endif
 #ifndef MSG_FASTOPEN
 #define MSG_FASTOPEN		0x20000000
 #endif
