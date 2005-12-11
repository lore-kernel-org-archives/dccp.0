From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 11 Dec 2005 13:56:42 +0000
Subject: [PATCH 2/4][DCCP]: Use reqsk_free in dccp_v4_conn_request
Message-Id: <39e6f6c70512110556n4d8f620dj4d907084d59cc66a@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_29627_14135920.1134309402786"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_29627_14135920.1134309402786
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_29627_14135920.1134309402786
Content-Type: text/x-patch; name=2.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="2.patch"

tree ac1d79fd17d21f598047598d408299637b62f37d
parent 582d6eefc1777888941300a74fcb5ecb810fb3a4
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134303864 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134303864 -0200

[DCCP]: Use reqsk_free in dccp_v4_conn_request

Now we have the destructor (dccp_v4_reqsk_destructor) in our request_sock_ops
vtable.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ipv4.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 83ea891..acdd96c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -721,10 +721,7 @@ int dccp_v4_conn_request(struct sock *sk
 	return 0;
 
 drop_and_free:
-	/*
-	 * FIXME: should be reqsk_free after implementing req->rsk_ops
-	 */
-	__reqsk_free(req);
+	reqsk_free(req);
 drop:
 	DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
 	dcb->dccpd_reset_code = reset_code;

------=_Part_29627_14135920.1134309402786--
