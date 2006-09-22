From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Sep 2006 08:33:58 +0000
Subject: Re: [PATCH] net/dccp: Allow default/fallback service code
Message-Id: <200609220933.58965@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609111922.12855@strip-the-willow>
In-Reply-To: <200609111922.12855@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: If an application does not want to provide a service code, that's
        fine, it will be given 0. Otherwise, service codes can be set
        via socket options as before.

        This has fixes as below.

|  Not sure what happened here but I can't apply this with git-apply. Can
|  you check and resubmit. Looks great patch though and would love to
|  test! This would mean DCCP is easier to port to which must be good.
You are right; sorry - I normally do patches for every possible kernel
version and I accidentally submitted the one for the stable kernel. 
This one patches correctly against David's 2.6.19 tree and is the same,
tested and verified code. 
  
|  Just a quick note - you didn't updated last changed date in
|  Documentation/networking/dccp.txt. I think rather than updating you
|  can remove as people can find dates by looking at git history.
I have done this also. Thank you for checking.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
--
 Documentation/networking/dccp.txt |    8 +++++---
 include/linux/dccp.h              |    6 +-----
 net/dccp/ipv4.c                   |    3 ---
 net/dccp/proto.c                  |   11 +----------
 4 files changed, 7 insertions(+), 21 deletions(-)


diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index c45daab..74563b3 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -1,7 +1,6 @@
 DCCP protocol
 ======
 
-Last updated: 10 November 2005
 
 Contents
 ====
@@ -42,8 +41,11 @@ Socket options
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
index 2d7671c..29f9291 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -404,6 +404,7 @@ struct dccp_service_list {
 };
 
 #define DCCP_SERVICE_INVALID_VALUE htonl((__u32)-1)
+#define DCCP_SERVICE_CODE_IS_ABSENT 		 0
 
 static inline int dccp_list_has_service(const struct dccp_service_list *sl,
 					const __be32 service)
@@ -484,11 +485,6 @@ static inline struct dccp_minisock *dccp
 	return (struct dccp_minisock *)&dccp_sk(sk)->dccps_minisock;
 }
 
-static inline int dccp_service_not_initialized(const struct sock *sk)
-{
-	return dccp_sk(sk)->dccps_service = DCCP_SERVICE_INVALID_VALUE;
-}
-
 static inline const char *dccp_role(const struct sock *sk)
 {
 	switch (dccp_sk(sk)->dccps_role) {
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 9a1a76a..66be29b 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -56,9 +56,6 @@ int dccp_v4_connect(struct sock *sk, str
 
 	dp->dccps_role = DCCP_ROLE_CLIENT;
 
-	if (dccp_service_not_initialized(sk))
-		return -EPROTO;
-
 	if (addr_len < sizeof(struct sockaddr_in))
 		return -EINVAL;
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 962df0e..72cbdcf 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -217,7 +217,7 @@ int dccp_init_sock(struct sock *sk, cons
 	icsk->icsk_sync_mss	= dccp_sync_mss;
 	dp->dccps_mss_cache	= 536;
 	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
-	dp->dccps_service	= DCCP_SERVICE_INVALID_VALUE;
+	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
 	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
 
 	return 0;
@@ -267,12 +267,6 @@ static inline int dccp_listen_start(stru
 	struct dccp_sock *dp = dccp_sk(sk);
 
 	dp->dccps_role = DCCP_ROLE_LISTEN;
-	/*
-	 * Apps need to use setsockopt(DCCP_SOCKOPT_SERVICE)
-	 * before calling listen()
-	 */
-	if (dccp_service_not_initialized(sk))
-		return -EPROTO;
 	return inet_csk_listen_start(sk, TCP_SYNQ_HSIZE);
 }
 
@@ -540,9 +534,6 @@ static int dccp_getsockopt_service(struc
 	int err = -ENOENT, slen = 0, total_len = sizeof(u32);
 
 	lock_sock(sk);
-	if (dccp_service_not_initialized(sk))
-		goto out;
-
 	if ((sl = dp->dccps_service_list) != NULL) {
 		slen = sl->dccpsl_nr * sizeof(u32);
 		total_len += slen;


