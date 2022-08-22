From: Joanne Koong <joannelkoong@gmail.com>
Date: Mon, 22 Aug 2022 18:10:23 +0000
Subject: [PATCH RESEND net-next v4 3/3] selftests/net: Add sk_bind_sendto_listen and sk_connect_zero_addr
Message-Id: <20220822181023.3979645-4-joannelkoong@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch adds 2 new tests: sk_bind_sendto_listen and
sk_connect_zero_addr.

The sk_bind_sendto_listen test exercises the path where a socket's
rcv saddr changes after it has been added to the binding tables,
and then a listen() on the socket is invoked. The listen() should
succeed.

The sk_bind_sendto_listen test is copied over from one of syzbot's
tests: https://syzkaller.appspot.com/x/repro.c?x=1673a38df00000

The sk_connect_zero_addr test exercises the path where the socket was
never previously added to the binding tables and it gets assigned a
saddr upon a connect() to address 0.

Signed-off-by: Joanne Koong <joannelkoong@gmail.com>
---
 tools/testing/selftests/net/.gitignore        |  2 +
 tools/testing/selftests/net/Makefile          |  2 +
 .../selftests/net/sk_bind_sendto_listen.c     | 80 +++++++++++++++++++
 .../selftests/net/sk_connect_zero_addr.c      | 62 ++++++++++++++
 4 files changed, 146 insertions(+)
 create mode 100644 tools/testing/selftests/net/sk_bind_sendto_listen.c
 create mode 100644 tools/testing/selftests/net/sk_connect_zero_addr.c

diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
index 89e2d4aa812a..bec5cf96984c 100644
--- a/tools/testing/selftests/net/.gitignore
+++ b/tools/testing/selftests/net/.gitignore
@@ -41,3 +41,5 @@ cmsg_sender
 unix_connect
 tap
 bind_bhash
+sk_bind_sendto_listen
+sk_connect_zero_addr
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index b17ec78f3951..e6a951ba5ba0 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -66,6 +66,8 @@ TEST_GEN_FILES += stress_reuseport_listen
 TEST_PROGS += test_vxlan_vnifiltering.sh
 TEST_GEN_FILES += io_uring_zerocopy_tx
 TEST_GEN_FILES += bind_bhash
+TEST_GEN_PROGS += sk_bind_sendto_listen
+TEST_GEN_PROGS += sk_connect_zero_addr
 
 TEST_FILES := settings
 
diff --git a/tools/testing/selftests/net/sk_bind_sendto_listen.c b/tools/testing/selftests/net/sk_bind_sendto_listen.c
new file mode 100644
index 000000000000..b420d830f72c
--- /dev/null
+++ b/tools/testing/selftests/net/sk_bind_sendto_listen.c
@@ -0,0 +1,80 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <arpa/inet.h>
+#include <error.h>
+#include <errno.h>
+#include <unistd.h>
+
+int main(void)
+{
+	int fd1, fd2, one = 1;
+	struct sockaddr_in6 bind_addr = {
+		.sin6_family = AF_INET6,
+		.sin6_port = htons(20000),
+		.sin6_flowinfo = htonl(0),
+		.sin6_addr = {},
+		.sin6_scope_id = 0,
+	};
+
+	inet_pton(AF_INET6, "::", &bind_addr.sin6_addr);
+
+	fd1 = socket(AF_INET6, SOCK_STREAM, IPPROTO_IP);
+	if (fd1 < 0) {
+		error(1, errno, "socket fd1");
+		return -1;
+	}
+
+	if (setsockopt(fd1, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one))) {
+		error(1, errno, "setsockopt(SO_REUSEADDR) fd1");
+		goto out_err1;
+	}
+
+	if (bind(fd1, (struct sockaddr *)&bind_addr, sizeof(bind_addr))) {
+		error(1, errno, "bind fd1");
+		goto out_err1;
+	}
+
+	if (sendto(fd1, NULL, 0, MSG_FASTOPEN, (struct sockaddr *)&bind_addr,
+		   sizeof(bind_addr))) {
+		error(1, errno, "sendto fd1");
+		goto out_err1;
+	}
+
+	fd2 = socket(AF_INET6, SOCK_STREAM, IPPROTO_IP);
+	if (fd2 < 0) {
+		error(1, errno, "socket fd2");
+		goto out_err1;
+	}
+
+	if (setsockopt(fd2, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one))) {
+		error(1, errno, "setsockopt(SO_REUSEADDR) fd2");
+		goto out_err2;
+	}
+
+	if (bind(fd2, (struct sockaddr *)&bind_addr, sizeof(bind_addr))) {
+		error(1, errno, "bind fd2");
+		goto out_err2;
+	}
+
+	if (sendto(fd2, NULL, 0, MSG_FASTOPEN, (struct sockaddr *)&bind_addr,
+		   sizeof(bind_addr)) != -1) {
+		error(1, errno, "sendto fd2");
+		goto out_err2;
+	}
+
+	if (listen(fd2, 0)) {
+		error(1, errno, "listen");
+		goto out_err2;
+	}
+
+	close(fd2);
+	close(fd1);
+	return 0;
+
+out_err2:
+	close(fd2);
+
+out_err1:
+	close(fd1);
+	return -1;
+}
diff --git a/tools/testing/selftests/net/sk_connect_zero_addr.c b/tools/testing/selftests/net/sk_connect_zero_addr.c
new file mode 100644
index 000000000000..4be418aefd9f
--- /dev/null
+++ b/tools/testing/selftests/net/sk_connect_zero_addr.c
@@ -0,0 +1,62 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <arpa/inet.h>
+#include <error.h>
+#include <errno.h>
+#include <unistd.h>
+
+int main(void)
+{
+	int fd1, fd2, one = 1;
+	struct sockaddr_in6 bind_addr = {
+		.sin6_family = AF_INET6,
+		.sin6_port = htons(20000),
+		.sin6_flowinfo = htonl(0),
+		.sin6_addr = {},
+		.sin6_scope_id = 0,
+	};
+
+	inet_pton(AF_INET6, "::", &bind_addr.sin6_addr);
+
+	fd1 = socket(AF_INET6, SOCK_STREAM, IPPROTO_IP);
+	if (fd1 < 0) {
+		error(1, errno, "socket fd1");
+		return -1;
+	}
+
+	if (setsockopt(fd1, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one))) {
+		error(1, errno, "setsockopt(SO_REUSEADDR) fd1");
+		goto out_err1;
+	}
+
+	if (bind(fd1, (struct sockaddr *)&bind_addr, sizeof(bind_addr))) {
+		error(1, errno, "bind fd1");
+		goto out_err1;
+	}
+
+	if (listen(fd1, 0)) {
+		error(1, errno, "listen");
+		goto out_err1;
+	}
+
+	fd2 = socket(AF_INET6, SOCK_STREAM, IPPROTO_IP);
+	if (fd2 < 0) {
+		error(1, errno, "socket fd2");
+		goto out_err1;
+	}
+
+	if (connect(fd2, (struct sockaddr *)&bind_addr, sizeof(bind_addr))) {
+		error(1, errno, "bind fd2");
+		goto out_err2;
+	}
+
+	close(fd2);
+	close(fd1);
+	return 0;
+
+out_err2:
+	close(fd2);
+out_err1:
+	close(fd1);
+	return -1;
+}
-- 
2.30.2
