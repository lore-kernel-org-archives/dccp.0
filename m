From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 03 Nov 2006 14:32:16 +0000
Subject: [PATCH 1/6] dccp: The return of Unload Hack
Message-Id: <200611031432.17083@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: The return of Unload Hack

At present it is not possible to unload any of the dccp_ipv{4,6} modules -
not even with force.

The reason is that the control socket is not released at module exit; this known
problem had been fixed up to 2.6.17-rc1 by a solution known as the Unload Hack.

This patch resolves the problem by releasing the control sockets for the v4/v6
modules in the module exit function. [ The test whether ctl_sock != NULL has
been deleted since __sock_create (via inet_csk_ctl_sock_create) returns an
error code different from 0 whenever sock != NULL. ]

There may be more elegant solutions, but this one is simple and  works.
An `under construction' warning is added, that it is currently not advisable
to unload the dccp_ipv{4,6} modules.

Note: This solution mirrors the one in SCTP, which can also only be ejected
      using rmmod --force: maybe there is room for a generic solution to both,
      since the key problem in both is in releasing the control socket.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c |    5 +++++
 net/dccp/ipv6.c |    2 ++
 2 files changed, 7 insertions(+)


--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1065,6 +1065,7 @@ static int __init dccp_v4_init(void)
 				       SOCK_DCCP, IPPROTO_DCCP);
 	if (err)
 		goto out_unregister_protosw;
+	__unsafe(THIS_MODULE);		/* due to unload hack in dccp_v4_exit */
 out:
 	return err;
 out_unregister_protosw:
@@ -1077,6 +1078,10 @@ out_proto_unregister:
 
 static void __exit dccp_v4_exit(void)
 {
+	/* FIXME: Unload Hack - must release control socket to unload.
+	 * There should be a better solution to release the control socket,
+	 * until this is resolved, please keep the above __unsafe warning. */
+	sock_release(dccp_v4_ctl_socket);
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
 	proto_unregister(&dccp_v4_prot);
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1237,6 +1237,7 @@ static int __init dccp_v6_init(void)
 				       SOCK_DCCP, IPPROTO_DCCP);
 	if (err != 0)
 		goto out_unregister_protosw;
+	__unsafe(THIS_MODULE);		/* due to unload hack in dccp_v6_exit */
 out:
 	return err;
 out_unregister_protosw:
@@ -1249,6 +1250,7 @@ out_unregister_proto:
 
 static void __exit dccp_v6_exit(void)
 {
+	sock_release(dccp_v6_ctl_socket);  /* FIXME: see note in dccp_v4_exit */
 	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
 	inet6_unregister_protosw(&dccp_v6_protosw);
 	proto_unregister(&dccp_v6_prot);
