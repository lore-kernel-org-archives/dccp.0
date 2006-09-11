From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Sep 2006 18:22:12 +0000
Subject: [PATCH] net/dccp: Allow default/fallback service code
Message-Id: <200609111922.12855@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Allow default/fallback service code.

This has been discussed on dccp@vger and removes the necessity for
applications to supply service codes in each and every case. 

If an application does not want to provide a service code, that's
fine, it will be given 0. Otherwise, service codes can be set
via socket options as before.

This patch has been tested using various client/server configurations
(including listening on multiple service codes) and patches against
Torvalds' tree.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
--
 Documentation/networking/dccp.txt |    7 +++++--
 include/linux/dccp.h              |    6 +-----
 net/dccp/ipv4.c                   |    3 ---
 net/dccp/proto.c                  |   11 +----------
 4 files changed, 7 insertions(+), 20 deletions(-)


diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index c45daab..2f479af 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -42,8 +42,11 @@ Socket options
 DCCP_SOCKOPT_PACKET_SIZE is used for CCID3 to set default packet size for
 calculations.

-DCCP_SOCKOPT_SERVICE sets the service. This is compulsory as per the
-specification. If you don't set it you will get EPROTO.
+DCCP_SOCKOPT_SERVICE sets the service. The specification mandates use of
+service codes (RFC 4340, sec. 8.1.2); if this socket option is not set,
+the socket will fall back to 0 (which means that no meaningful service code
+is present). Connecting sockets set at most one service option; for
+listening sockets, multiple service codes can be specified.

 Notes
 ==diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 676333b..30ce4b3 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -404,6 +404,7 @@ struct dccp_service_list {
 };

 #define DCCP_SERVICE_INVALID_VALUE htonl((__u32)-1)
+#define DCCP_SERVICE_CODE_IS_ABSENT              0

 static inline int dccp_list_has_service(const struct dccp_service_list *sl,
                                        const __be32 service)
@@ -482,11 +483,6 @@ static inline struct dccp_minisock *dccp
        return (struct dccp_minisock *)&dccp_sk(sk)->dccps_minisock;
 }

-static inline int dccp_service_not_initialized(const struct sock *sk)
-{
-       return dccp_sk(sk)->dccps_service = DCCP_SERVICE_INVALID_VALUE;
-}
-
 static inline const char *dccp_role(const struct sock *sk)
 {
        switch (dccp_sk(sk)->dccps_role) {
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7f56f7e..ef60f4e 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -56,9 +56,6 @@ int dccp_v4_connect(struct sock *sk, str

        dp->dccps_role = DCCP_ROLE_CLIENT;

-       if (dccp_service_not_initialized(sk))
-               return -EPROTO;
-
        if (addr_len < sizeof(struct sockaddr_in))
                return -EINVAL;

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 6f14bb5..f1b88c8 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -217,7 +217,7 @@ int dccp_init_sock(struct sock *sk, cons
        icsk->icsk_sync_mss     = dccp_sync_mss;
        dp->dccps_mss_cache     = 536;
        dp->dccps_role          = DCCP_ROLE_UNDEFINED;
-       dp->dccps_service       = DCCP_SERVICE_INVALID_VALUE;
+       dp->dccps_service       = DCCP_SERVICE_CODE_IS_ABSENT;
        dp->dccps_l_ack_ratio   = dp->dccps_r_ack_ratio = 1;

        return 0;
@@ -267,12 +267,6 @@ static inline int dccp_listen_start(stru
        struct dccp_sock *dp = dccp_sk(sk);

        dp->dccps_role = DCCP_ROLE_LISTEN;
-       /*
-        * Apps need to use setsockopt(DCCP_SOCKOPT_SERVICE)
-        * before calling listen()
-        */
-       if (dccp_service_not_initialized(sk))
-               return -EPROTO;
        return inet_csk_listen_start(sk, TCP_SYNQ_HSIZE);
 }

@@ -540,9 +534,6 @@ static int dccp_getsockopt_service(struc
        int err = -ENOENT, slen = 0, total_len = sizeof(u32);

        lock_sock(sk);
-       if (dccp_service_not_initialized(sk))
-               goto out;
-
        if ((sl = dp->dccps_service_list) != NULL) {
                slen = sl->dccpsl_nr * sizeof(u32);
                total_len += slen;

