From: James Morris <jmorris@namei.org>
Date: Sat, 11 Nov 2006 07:16:24 +0000
Subject: [PATCH RFC] SELinux support for DCCP
Message-Id: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch implements SELinux kernel support for DCCP 
(http://linux-net.osdl.org/index.php/DCCP), which is similar in operation 
to TCP in terms of connected state between peers.

The SELinux support for DCCP is thus modeled on existing handling of TCP.

A new DCCP socket class is introduced, to allow protocol differentation.  
The permissions for this class inherit all of the socket permissions, as 
well as the current TCP permissions (node_bind, name_bind etc). IPv4 and 
IPv6 are supported, although labeled networking is not, at this stage.

Patches for SELinux userspace are at:
http://people.redhat.com/jmorris/selinux/dccp/user/

I've performed some basic testing, and it seems to be working as expected.  
Adding policy support is similar to TCP, the only real difference being 
that it's a different protocol.

The kernel patch is included below, please review.

Signed-off-by: James Morris <jmorris@namei.org>

---

 security/selinux/hooks.c                     |   60 ++++++++++++++++++++++++---
 security/selinux/include/av_inherit.h        |    1 
 security/selinux/include/av_perm_to_string.h |    8 +++
 security/selinux/include/av_permissions.h    |   32 ++++++++++++++
 security/selinux/include/class_to_string.h   |    2 
 security/selinux/include/flask.h             |    2 
 6 files changed, 100 insertions(+), 5 deletions(-)

diff -purN -X dontdiff linux-2.6.o/security/selinux/hooks.c linux-2.6.w/security/selinux/hooks.c
--- linux-2.6.o/security/selinux/hooks.c	2006-10-31 14:33:11.000000000 -0500
+++ linux-2.6.w/security/selinux/hooks.c	2006-11-11 00:05:25.000000000 -0500
@@ -58,6 +58,7 @@
 #include <linux/netlink.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
+#include <linux/dccp.h>
 #include <linux/quota.h>
 #include <linux/un.h>		/* for Unix socket types */
 #include <net/af_unix.h>	/* for Unix socket types */
@@ -751,6 +752,8 @@ static inline u16 socket_type_to_securit
 				return SECCLASS_UDP_SOCKET;
 			else
 				return SECCLASS_RAWIP_SOCKET;
+		case SOCK_DCCP:
+			return SECCLASS_DCCP_SOCKET;
 		default:
 			return SECCLASS_RAWIP_SOCKET;
 		}
@@ -2939,6 +2942,22 @@ static int selinux_parse_skb_ipv4(struct
         	break;
         }
 
+	case IPPROTO_DCCP: {
+		struct dccp_hdr _dccph, *dh;
+
+		if (ntohs(ih->frag_off) & IP_OFFSET)
+			break;
+			
+		offset += ihlen;
+		dh = skb_header_pointer(skb, offset, sizeof(_dccph), &_dccph);
+		if (dh = NULL)
+			break;
+			
+		ad->u.net.sport = dh->dccph_sport;
+		ad->u.net.dport = dh->dccph_dport;
+		break;
+        }
+
         default:
         	break;
         }
@@ -2994,6 +3013,18 @@ static int selinux_parse_skb_ipv6(struct
 		ad->u.net.dport = uh->dest;
 		break;
 	}
+	
+	case IPPROTO_DCCP: {
+		struct dccp_hdr _dccph, *dh;
+
+		dh = skb_header_pointer(skb, offset, sizeof(_dccph), &_dccph);
+		if (dh = NULL)
+			break;
+			
+		ad->u.net.sport = dh->dccph_sport;
+		ad->u.net.dport = dh->dccph_dport;
+		break;
+        }
 
 	/* includes fragments */
 	default:
@@ -3180,6 +3211,10 @@ static int selinux_socket_bind(struct so
 			node_perm = UDP_SOCKET__NODE_BIND;
 			break;
 			
+		case SECCLASS_DCCP_SOCKET:
+			node_perm = DCCP_SOCKET__NODE_BIND;
+			break;
+
 		default:
 			node_perm = RAWIP_SOCKET__NODE_BIND;
 			break;
@@ -3217,16 +3252,17 @@ static int selinux_socket_connect(struct
 		return err;
 
 	/*
-	 * If a TCP socket, check name_connect permission for the port.
+	 * If a TCP or DCCP socket, check name_connect permission for the port.
 	 */
 	isec = SOCK_INODE(sock)->i_security;
-	if (isec->sclass = SECCLASS_TCP_SOCKET) {
+	if (isec->sclass = SECCLASS_TCP_SOCKET ||
+	    isec->sclass = SECCLASS_DCCP_SOCKET) {
 		struct sock *sk = sock->sk;
 		struct avc_audit_data ad;
 		struct sockaddr_in *addr4 = NULL;
 		struct sockaddr_in6 *addr6 = NULL;
 		unsigned short snum;
-		u32 sid;
+		u32 sid, perm;
 
 		if (sk->sk_family = PF_INET) {
 			addr4 = (struct sockaddr_in *)address;
@@ -3245,11 +3281,13 @@ static int selinux_socket_connect(struct
 		if (err)
 			goto out;
 
+		perm = (isec->sclass = SECCLASS_TCP_SOCKET) ?
+		       TCP_SOCKET__NAME_CONNECT : DCCP_SOCKET__NAME_CONNECT;
+		
 		AVC_AUDIT_DATA_INIT(&ad,NET);
 		ad.u.net.dport = htons(snum);
 		ad.u.net.family = sk->sk_family;
-		err = avc_has_perm(isec->sid, sid, isec->sclass,
-				   TCP_SOCKET__NAME_CONNECT, &ad);
+		err = avc_has_perm(isec->sid, sid, isec->sclass, perm, &ad);
 		if (err)
 			goto out;
 	}
@@ -3438,6 +3476,12 @@ static int selinux_sock_rcv_skb_compat(s
 		recv_perm = TCP_SOCKET__RECV_MSG;
 		break;
 	
+	case SECCLASS_DCCP_SOCKET:
+		netif_perm = NETIF__DCCP_RECV;
+		node_perm = NODE__DCCP_RECV;
+		recv_perm = DCCP_SOCKET__RECV_MSG;
+		break;
+	
 	default:
 		netif_perm = NETIF__RAWIP_RECV;
 		node_perm = NODE__RAWIP_RECV;
@@ -3757,6 +3801,12 @@ static int selinux_ip_postroute_last_com
 		send_perm = TCP_SOCKET__SEND_MSG;
 		break;
 	
+	case SECCLASS_DCCP_SOCKET:
+		netif_perm = NETIF__DCCP_SEND;
+		node_perm = NODE__DCCP_SEND;
+		send_perm = DCCP_SOCKET__SEND_MSG;
+		break;
+	
 	default:
 		netif_perm = NETIF__RAWIP_SEND;
 		node_perm = NODE__RAWIP_SEND;
diff -purN -X dontdiff linux-2.6.o/security/selinux/include/av_inherit.h linux-2.6.w/security/selinux/include/av_inherit.h
--- linux-2.6.o/security/selinux/include/av_inherit.h	2006-09-23 23:33:32.000000000 -0400
+++ linux-2.6.w/security/selinux/include/av_inherit.h	2006-11-10 23:35:14.000000000 -0500
@@ -30,3 +30,4 @@
    S_(SECCLASS_NETLINK_DNRT_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_APPLETALK_SOCKET, socket, 0x00400000UL)
+   S_(SECCLASS_DCCP_SOCKET, socket, 0x00400000UL)
diff -purN -X dontdiff linux-2.6.o/security/selinux/include/av_permissions.h linux-2.6.w/security/selinux/include/av_permissions.h
--- linux-2.6.o/security/selinux/include/av_permissions.h	2006-09-23 23:33:32.000000000 -0400
+++ linux-2.6.w/security/selinux/include/av_permissions.h	2006-11-11 00:31:28.000000000 -0500
@@ -312,6 +312,8 @@
 #define NODE__RAWIP_RECV                          0x00000010UL
 #define NODE__RAWIP_SEND                          0x00000020UL
 #define NODE__ENFORCE_DEST                        0x00000040UL
+#define NODE__DCCP_RECV                           0x00000080UL
+#define NODE__DCCP_SEND                           0x00000100UL
 
 #define NETIF__TCP_RECV                           0x00000001UL
 #define NETIF__TCP_SEND                           0x00000002UL
@@ -319,6 +321,8 @@
 #define NETIF__UDP_SEND                           0x00000008UL
 #define NETIF__RAWIP_RECV                         0x00000010UL
 #define NETIF__RAWIP_SEND                         0x00000020UL
+#define NETIF__DCCP_RECV                          0x00000040UL
+#define NETIF__DCCP_SEND                          0x00000080UL
 
 #define NETLINK_SOCKET__IOCTL                     0x00000001UL
 #define NETLINK_SOCKET__READ                      0x00000002UL
@@ -970,3 +974,31 @@
 #define KEY__LINK                                 0x00000010UL
 #define KEY__SETATTR                              0x00000020UL
 #define KEY__CREATE                               0x00000040UL
+
+#define CONTEXT__TRANSLATE                        0x00000001UL
+#define CONTEXT__CONTAINS                         0x00000002UL
+  
+#define DCCP_SOCKET__IOCTL                        0x00000001UL
+#define DCCP_SOCKET__READ                         0x00000002UL
+#define DCCP_SOCKET__WRITE                        0x00000004UL
+#define DCCP_SOCKET__CREATE                       0x00000008UL
+#define DCCP_SOCKET__GETATTR                      0x00000010UL
+#define DCCP_SOCKET__SETATTR                      0x00000020UL
+#define DCCP_SOCKET__LOCK                         0x00000040UL
+#define DCCP_SOCKET__RELABELFROM                  0x00000080UL
+#define DCCP_SOCKET__RELABELTO                    0x00000100UL
+#define DCCP_SOCKET__APPEND                       0x00000200UL
+#define DCCP_SOCKET__BIND                         0x00000400UL
+#define DCCP_SOCKET__CONNECT                      0x00000800UL
+#define DCCP_SOCKET__LISTEN                       0x00001000UL
+#define DCCP_SOCKET__ACCEPT                       0x00002000UL
+#define DCCP_SOCKET__GETOPT                       0x00004000UL
+#define DCCP_SOCKET__SETOPT                       0x00008000UL
+#define DCCP_SOCKET__SHUTDOWN                     0x00010000UL
+#define DCCP_SOCKET__RECVFROM                     0x00020000UL
+#define DCCP_SOCKET__SENDTO                       0x00040000UL
+#define DCCP_SOCKET__RECV_MSG                     0x00080000UL
+#define DCCP_SOCKET__SEND_MSG                     0x00100000UL
+#define DCCP_SOCKET__NAME_BIND                    0x00200000UL
+#define DCCP_SOCKET__NODE_BIND                    0x00400000UL
+#define DCCP_SOCKET__NAME_CONNECT                 0x00800000UL
diff -purN -X dontdiff linux-2.6.o/security/selinux/include/av_perm_to_string.h linux-2.6.w/security/selinux/include/av_perm_to_string.h
--- linux-2.6.o/security/selinux/include/av_perm_to_string.h	2006-09-23 23:33:32.000000000 -0400
+++ linux-2.6.w/security/selinux/include/av_perm_to_string.h	2006-11-11 00:29:30.000000000 -0500
@@ -35,12 +35,16 @@
    S_(SECCLASS_NODE, NODE__RAWIP_RECV, "rawip_recv")
    S_(SECCLASS_NODE, NODE__RAWIP_SEND, "rawip_send")
    S_(SECCLASS_NODE, NODE__ENFORCE_DEST, "enforce_dest")
+   S_(SECCLASS_NODE, NODE__DCCP_RECV, "dccp_recv")
+   S_(SECCLASS_NODE, NODE__DCCP_SEND, "dccp_send")
    S_(SECCLASS_NETIF, NETIF__TCP_RECV, "tcp_recv")
    S_(SECCLASS_NETIF, NETIF__TCP_SEND, "tcp_send")
    S_(SECCLASS_NETIF, NETIF__UDP_RECV, "udp_recv")
    S_(SECCLASS_NETIF, NETIF__UDP_SEND, "udp_send")
    S_(SECCLASS_NETIF, NETIF__RAWIP_RECV, "rawip_recv")
    S_(SECCLASS_NETIF, NETIF__RAWIP_SEND, "rawip_send")
+   S_(SECCLASS_NETIF, NETIF__DCCP_RECV, "dccp_recv")
+   S_(SECCLASS_NETIF, NETIF__DCCP_SEND, "dccp_send")
    S_(SECCLASS_UNIX_STREAM_SOCKET, UNIX_STREAM_SOCKET__CONNECTTO, "connectto")
    S_(SECCLASS_UNIX_STREAM_SOCKET, UNIX_STREAM_SOCKET__NEWCONN, "newconn")
    S_(SECCLASS_UNIX_STREAM_SOCKET, UNIX_STREAM_SOCKET__ACCEPTFROM, "acceptfrom")
@@ -252,3 +256,7 @@
    S_(SECCLASS_KEY, KEY__LINK, "link")
    S_(SECCLASS_KEY, KEY__SETATTR, "setattr")
    S_(SECCLASS_KEY, KEY__CREATE, "create")
+   S_(SECCLASS_CONTEXT, CONTEXT__TRANSLATE, "translate")
+   S_(SECCLASS_CONTEXT, CONTEXT__CONTAINS, "contains")
+   S_(SECCLASS_DCCP_SOCKET, DCCP_SOCKET__NODE_BIND, "node_bind")
+   S_(SECCLASS_DCCP_SOCKET, DCCP_SOCKET__NAME_CONNECT, "name_connect")
diff -purN -X dontdiff linux-2.6.o/security/selinux/include/class_to_string.h linux-2.6.w/security/selinux/include/class_to_string.h
--- linux-2.6.o/security/selinux/include/class_to_string.h	2006-09-23 23:33:32.000000000 -0400
+++ linux-2.6.w/security/selinux/include/class_to_string.h	2006-11-11 00:29:49.000000000 -0500
@@ -61,3 +61,5 @@
     S_("appletalk_socket")
     S_("packet")
     S_("key")
+    S_("context")
+    S_("dccp_socket")
diff -purN -X dontdiff linux-2.6.o/security/selinux/include/flask.h linux-2.6.w/security/selinux/include/flask.h
--- linux-2.6.o/security/selinux/include/flask.h	2006-09-23 23:33:32.000000000 -0400
+++ linux-2.6.w/security/selinux/include/flask.h	2006-11-11 00:28:31.000000000 -0500
@@ -63,6 +63,8 @@
 #define SECCLASS_APPLETALK_SOCKET                        56
 #define SECCLASS_PACKET                                  57
 #define SECCLASS_KEY                                     58
+#define SECCLASS_CONTEXT                                 59
+#define SECCLASS_DCCP_SOCKET                             60
 
 /*
  * Security identifier indices for initial entities
