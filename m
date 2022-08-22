From: Joanne Koong <joannelkoong@gmail.com>
Date: Mon, 22 Aug 2022 18:10:22 +0000
Subject: [PATCH RESEND net-next v4 2/3] selftests/net: Add test for timing a bind request to a port with a po
Message-Id: <20220822181023.3979645-3-joannelkoong@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This test populates the bhash table for a given port with
MAX_THREADS * MAX_CONNECTIONS sockets, and then times how long
a bind request on the port takes.

When populating the bhash table, we create the sockets and then bind
the sockets to the same address and port (SO_REUSEADDR and SO_REUSEPORT
are set). When timing how long a bind on the port takes, we bind on a
different address without SO_REUSEPORT set. We do not set SO_REUSEPORT
because we are interested in the case where the bind request does not
go through the tb->fastreuseport path, which is fragile (eg
tb->fastreuseport path does not work if binding with a different uid).

To run the script:
    Usage: ./bind_bhash.sh [-6 | -4] [-p port] [-a address]
	    6: use ipv6
	    4: use ipv4
	    port: Port number
	    address: ip address

Without any arguments, ./bind_bhash.sh defaults to ipv6 using ip address
"2001:0db8:0:f101::1" on port 443.

On my local machine, I see:
ipv4:
before - 0.002317 seconds
with bhash2 - 0.000020 seconds

ipv6:
before - 0.002431 seconds
with bhash2 - 0.000021 seconds

Signed-off-by: Joanne Koong <joannelkoong@gmail.com>
---
 tools/testing/selftests/net/.gitignore    |   3 +-
 tools/testing/selftests/net/Makefile      |   3 +
 tools/testing/selftests/net/bind_bhash.c  | 144 ++++++++++++++++++++++
 tools/testing/selftests/net/bind_bhash.sh |  66 ++++++++++
 4 files changed, 215 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/net/bind_bhash.c
 create mode 100755 tools/testing/selftests/net/bind_bhash.sh

diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
index 0e5751af6247..89e2d4aa812a 100644
--- a/tools/testing/selftests/net/.gitignore
+++ b/tools/testing/selftests/net/.gitignore
@@ -39,4 +39,5 @@ toeplitz
 tun
 cmsg_sender
 unix_connect
-tap
\ No newline at end of file
+tap
+bind_bhash
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 11a288b67e2f..b17ec78f3951 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -43,6 +43,7 @@ TEST_PROGS += ndisc_unsolicited_na_test.sh
 TEST_PROGS += arp_ndisc_untracked_subnets.sh
 TEST_PROGS += stress_reuseport_listen.sh
 TEST_PROGS := l2_tos_ttl_inherit.sh
+TEST_PROGS += bind_bhash.sh
 TEST_PROGS_EXTENDED := in_netns.sh setup_loopback.sh setup_veth.sh
 TEST_PROGS_EXTENDED += toeplitz_client.sh toeplitz.sh
 TEST_GEN_FILES =  socket nettest
@@ -64,6 +65,7 @@ TEST_GEN_FILES += cmsg_sender
 TEST_GEN_FILES += stress_reuseport_listen
 TEST_PROGS += test_vxlan_vnifiltering.sh
 TEST_GEN_FILES += io_uring_zerocopy_tx
+TEST_GEN_FILES += bind_bhash
 
 TEST_FILES := settings
 
@@ -74,3 +76,4 @@ include bpf/Makefile
 $(OUTPUT)/reuseport_bpf_numa: LDLIBS += -lnuma
 $(OUTPUT)/tcp_mmap: LDLIBS += -lpthread
 $(OUTPUT)/tcp_inq: LDLIBS += -lpthread
+$(OUTPUT)/bind_bhash: LDLIBS += -lpthread
diff --git a/tools/testing/selftests/net/bind_bhash.c b/tools/testing/selftests/net/bind_bhash.c
new file mode 100644
index 000000000000..57ff67a3751e
--- /dev/null
+++ b/tools/testing/selftests/net/bind_bhash.c
@@ -0,0 +1,144 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * This times how long it takes to bind to a port when the port already
+ * has multiple sockets in its bhash table.
+ *
+ * In the setup(), we populate the port's bhash table with
+ * MAX_THREADS * MAX_CONNECTIONS number of entries.
+ */
+
+#include <unistd.h>
+#include <stdio.h>
+#include <netdb.h>
+#include <pthread.h>
+#include <string.h>
+#include <stdbool.h>
+
+#define MAX_THREADS 600
+#define MAX_CONNECTIONS 40
+
+static const char *setup_addr_v6 = "::1";
+static const char *setup_addr_v4 = "127.0.0.1";
+static const char *setup_addr;
+static const char *bind_addr;
+static const char *port;
+bool use_v6;
+int ret;
+
+static int fd_array[MAX_THREADS][MAX_CONNECTIONS];
+
+static int bind_socket(int opt, const char *addr)
+{
+	struct addrinfo *res, hint = {};
+	int sock_fd, reuse = 1, err;
+	int domain = use_v6 ? AF_INET6 : AF_INET;
+
+	sock_fd = socket(domain, SOCK_STREAM, 0);
+	if (sock_fd < 0) {
+		perror("socket fd err");
+		return sock_fd;
+	}
+
+	hint.ai_family = domain;
+	hint.ai_socktype = SOCK_STREAM;
+
+	err = getaddrinfo(addr, port, &hint, &res);
+	if (err) {
+		perror("getaddrinfo failed");
+		goto cleanup;
+	}
+
+	if (opt) {
+		err = setsockopt(sock_fd, SOL_SOCKET, opt, &reuse, sizeof(reuse));
+		if (err) {
+			perror("setsockopt failed");
+			goto cleanup;
+		}
+	}
+
+	err = bind(sock_fd, res->ai_addr, res->ai_addrlen);
+	if (err) {
+		perror("failed to bind to port");
+		goto cleanup;
+	}
+
+	return sock_fd;
+
+cleanup:
+	close(sock_fd);
+	return err;
+}
+
+static void *setup(void *arg)
+{
+	int sock_fd, i;
+	int *array = (int *)arg;
+
+	for (i = 0; i < MAX_CONNECTIONS; i++) {
+		sock_fd = bind_socket(SO_REUSEADDR | SO_REUSEPORT, setup_addr);
+		if (sock_fd < 0) {
+			ret = sock_fd;
+			pthread_exit(&ret);
+		}
+		array[i] = sock_fd;
+	}
+
+	return NULL;
+}
+
+int main(int argc, const char *argv[])
+{
+	int listener_fd, sock_fd, i, j;
+	pthread_t tid[MAX_THREADS];
+	clock_t begin, end;
+
+	if (argc != 4) {
+		printf("Usage: listener <port> <ipv6 | ipv4> <bind-addr>\n");
+		return -1;
+	}
+
+	port = argv[1];
+	use_v6 = strcmp(argv[2], "ipv6") == 0;
+	bind_addr = argv[3];
+
+	setup_addr = use_v6 ? setup_addr_v6 : setup_addr_v4;
+
+	listener_fd = bind_socket(SO_REUSEADDR | SO_REUSEPORT, setup_addr);
+	if (listen(listener_fd, 100) < 0) {
+		perror("listen failed");
+		return -1;
+	}
+
+	/* Set up threads to populate the bhash table entry for the port */
+	for (i = 0; i < MAX_THREADS; i++)
+		pthread_create(&tid[i], NULL, setup, fd_array[i]);
+
+	for (i = 0; i < MAX_THREADS; i++)
+		pthread_join(tid[i], NULL);
+
+	if (ret)
+		goto done;
+
+	begin = clock();
+
+	/* Bind to the same port on a different address */
+	sock_fd  = bind_socket(0, bind_addr);
+	if (sock_fd < 0)
+		goto done;
+
+	end = clock();
+
+	printf("time spent = %f\n", (double)(end - begin) / CLOCKS_PER_SEC);
+
+	/* clean up */
+	close(sock_fd);
+
+done:
+	close(listener_fd);
+	for (i = 0; i < MAX_THREADS; i++) {
+		for (j = 0; i < MAX_THREADS; i++)
+			close(fd_array[i][j]);
+	}
+
+	return 0;
+}
diff --git a/tools/testing/selftests/net/bind_bhash.sh b/tools/testing/selftests/net/bind_bhash.sh
new file mode 100755
index 000000000000..ca0292d4b441
--- /dev/null
+++ b/tools/testing/selftests/net/bind_bhash.sh
@@ -0,0 +1,66 @@
+#!/bin/bash
+# SPDX-License-Identifier: GPL-2.0
+
+NR_FILES=32768
+SAVED_NR_FILES=$(ulimit -n)
+
+# default values
+port=443
+addr_v6="2001:0db8:0:f101::1"
+addr_v4="10.8.8.8"
+use_v6=true
+addr=""
+
+usage() {
+    echo "Usage: $0 [-6 | -4] [-p port] [-a address]"
+    echo -e "\t6: use ipv6"
+    echo -e "\t4: use ipv4"
+    echo -e "\tport: Port number"
+    echo -e "\taddress: ip address"
+}
+
+while getopts "ha:p:64" opt; do
+    case ${opt} in
+	h)
+	    usage $0
+	    exit 0
+	    ;;
+	a)  addr=$OPTARG;;
+	p)
+	    port=$OPTARG;;
+	6)
+	    use_v6=true;;
+	4)
+	    use_v6=false;;
+    esac
+done
+
+setup() {
+    if [[ "$use_v6" == true ]]; then
+	ip addr add $addr_v6 nodad dev eth0
+    else
+	ip addr add $addr_v4 dev lo
+    fi
+	ulimit -n $NR_FILES
+}
+
+cleanup() {
+    if [[ "$use_v6" == true ]]; then
+	ip addr del $addr_v6 dev eth0
+    else
+	ip addr del $addr_v4/32 dev lo
+    fi
+    ulimit -n $SAVED_NR_FILES
+}
+
+if [[ "$addr" != "" ]]; then
+    addr_v4=$addr;
+    addr_v6=$addr;
+fi
+setup
+if [[ "$use_v6" == true ]] ; then
+    ./bind_bhash $port "ipv6" $addr_v6
+else
+    ./bind_bhash $port "ipv4" $addr_v4
+fi
+cleanup
-- 
2.30.2
