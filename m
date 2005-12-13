From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 13 Dec 2005 00:03:08 +0000
Subject: [PATCH 1/2][TCP]: Move the TCPF_ enum to tcp_states.h
Message-Id: <39e6f6c70512121603v63551b49y3566a3e916535d69@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_17710_16768905.1134432188064"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_17710_16768905.1134432188064
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

  Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

  With these two my old DCCPv6 tree finally gets completely submitted,
whee! :-) Now to  do new work :-)

Best Regards,

- Arnaldo

------=_Part_17710_16768905.1134432188064
Content-Type: text/x-patch; name=1.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="1.patch"

tree 43548c6bc8d43ef3dbf077d32ee4b495c46b4a78
parent 0c54986a2b9abe6295ccac354924f563fd5dfc9c
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134427004 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134427004 -0200

[TCP]: Move the TCPF_ enum to tcp_states.h

Upcoming patches will make, for instance, ip_sockglue.c need just this enum
and not all of tcp.h.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 linux/tcp.h      |   16 ----------------
 net/tcp_states.h |   16 ++++++++++++++++
 2 files changed, 16 insertions(+), 16 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4e14340..da38eea 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -55,22 +55,6 @@ struct tcphdr {
 	__u16	urg_ptr;
 };
 
-#define TCP_ACTION_FIN	(1 << 7)
-
-enum {
-  TCPF_ESTABLISHED = (1 << 1),
-  TCPF_SYN_SENT  = (1 << 2),
-  TCPF_SYN_RECV  = (1 << 3),
-  TCPF_FIN_WAIT1 = (1 << 4),
-  TCPF_FIN_WAIT2 = (1 << 5),
-  TCPF_TIME_WAIT = (1 << 6),
-  TCPF_CLOSE     = (1 << 7),
-  TCPF_CLOSE_WAIT = (1 << 8),
-  TCPF_LAST_ACK  = (1 << 9),
-  TCPF_LISTEN    = (1 << 10),
-  TCPF_CLOSING   = (1 << 11) 
-};
-
 /*
  *	The union cast uses a gcc extension to avoid aliasing problems
  *  (union is compatible to any of its members)
diff --git a/include/net/tcp_states.h b/include/net/tcp_states.h
index b9d4176..b0b6459 100644
--- a/include/net/tcp_states.h
+++ b/include/net/tcp_states.h
@@ -31,4 +31,20 @@ enum {
 
 #define TCP_STATE_MASK	0xF
 
+#define TCP_ACTION_FIN	(1 << 7)
+
+enum {
+	TCPF_ESTABLISHED = (1 << 1),
+	TCPF_SYN_SENT	 = (1 << 2),
+	TCPF_SYN_RECV	 = (1 << 3),
+	TCPF_FIN_WAIT1	 = (1 << 4),
+	TCPF_FIN_WAIT2	 = (1 << 5),
+	TCPF_TIME_WAIT	 = (1 << 6),
+	TCPF_CLOSE	 = (1 << 7),
+	TCPF_CLOSE_WAIT	 = (1 << 8),
+	TCPF_LAST_ACK	 = (1 << 9),
+	TCPF_LISTEN	 = (1 << 10),
+	TCPF_CLOSING	 = (1 << 11) 
+};
+
 #endif	/* _LINUX_TCP_STATES_H */

------=_Part_17710_16768905.1134432188064--
