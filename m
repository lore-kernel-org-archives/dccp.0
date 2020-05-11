From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Mon, 11 May 2020 18:52:14 +0000
Subject: [PATCH bpf-next v2 13/17] bpf: Sync linux/bpf.h to tools/
Message-Id: <20200511185218.1422406-14-jakub@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Newly added program, context type and helper is used by tests in a
subsequent patch. Synchronize the header file.

Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
---

Notes:
    v2:
    - Update after changes to bpf.h in earlier patch.

 tools/include/uapi/linux/bpf.h | 52 ++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 9d1932e23cec..03edf4ec7b7e 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -188,6 +188,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_STRUCT_OPS,
 	BPF_PROG_TYPE_EXT,
 	BPF_PROG_TYPE_LSM,
+	BPF_PROG_TYPE_SK_LOOKUP,
 };
 
 enum bpf_attach_type {
@@ -220,6 +221,7 @@ enum bpf_attach_type {
 	BPF_MODIFY_RETURN,
 	BPF_LSM_MAC,
 	BPF_TRACE_ITER,
+	BPF_SK_LOOKUP,
 	__MAX_BPF_ATTACH_TYPE
 };
 
@@ -3050,6 +3052,10 @@ union bpf_attr {
  *
  * int bpf_sk_assign(struct sk_buff *skb, struct bpf_sock *sk, u64 flags)
  *	Description
+ *		Helper is overloaded depending on BPF program type. This
+ *		description applies to **BPF_PROG_TYPE_SCHED_CLS** and
+ *		**BPF_PROG_TYPE_SCHED_ACT** programs.
+ *
  *		Assign the *sk* to the *skb*. When combined with appropriate
  *		routing configuration to receive the packet towards the socket,
  *		will cause *skb* to be delivered to the specified socket.
@@ -3070,6 +3076,38 @@ union bpf_attr {
  *					call from outside of TC ingress.
  *		* **-ESOCKTNOSUPPORT**	Socket type not supported (reuseport).
  *
+ * int bpf_sk_assign(struct bpf_sk_lookup *ctx, struct bpf_sock *sk, u64 flags)
+ *	Description
+ *		Helper is overloaded depending on BPF program type. This
+ *		description applies to **BPF_PROG_TYPE_SK_LOOKUP** programs.
+ *
+ *		Select the *sk* as a result of a socket lookup.
+ *
+ *		For the operation to succeed passed socket must be compatible
+ *		with the packet description provided by the *ctx* object.
+ *
+ *		L4 protocol (*IPPROTO_TCP* or *IPPROTO_UDP*) must be an exact
+ *		match. While IP family (*AF_INET* or *AF_INET6*) must be
+ *		compatible, that is IPv6 sockets that are not v6-only can be
+ *		selected for IPv4 packets.
+ *
+ *		Only TCP listeners and UDP sockets, that is sockets which have
+ *		*SOCK_RCU_FREE* flag set, can be selected.
+ *
+ *		The *flags* argument must be zero.
+ *	Return
+ *		0 on success, or a negative errno in case of failure.
+ *
+ *		**-EAFNOSUPPORT** is socket family (*sk->family*) is not
+ *		compatible with packet family (*ctx->family*).
+ *
+ *		**-EINVAL** if unsupported flags were specified.
+ *
+ *		**-EPROTOTYPE** if socket L4 protocol (*sk->protocol*) doesn't
+ *		match packet protocol (*ctx->protocol*).
+ *
+ *		**-ESOCKTNOSUPPORT** if socket does not use RCU freeing.
+ *
  * u64 bpf_ktime_get_boot_ns(void)
  * 	Description
  * 		Return the time elapsed since system boot, in nanoseconds.
@@ -4058,4 +4096,18 @@ struct bpf_pidns_info {
 	__u32 pid;
 	__u32 tgid;
 };
+
+/* User accessible data for SK_LOOKUP programs. Add new fields at the end. */
+struct bpf_sk_lookup {
+	__u32 family;		/* Protocol family (AF_INET, AF_INET6) */
+	__u32 protocol;		/* IP protocol (IPPROTO_TCP, IPPROTO_UDP) */
+	/* IP addresses allow 1,2,4-byte read and are in network byte order. */
+	__u32 remote_ip4;
+	__u32 remote_ip6[4];
+	__u32 remote_port;	/* network byte order */
+	__u32 local_ip4;
+	__u32 local_ip6[4];
+	__u32 local_port;	/* host byte order */
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
-- 
2.25.3
