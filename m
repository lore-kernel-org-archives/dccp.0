From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:38:02 +0000
Subject: [PATCH 2/11][DCCP]: Fix error handling in dccp_init
Message-Id: <39e6f6c70602031838o2e84cb34k6170211428251db@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11446_2002684.1139020682871"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11446_2002684.1139020682871
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11446_2002684.1139020682871
Content-Type: text/x-patch; name=2.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9b4tc5
Content-Disposition: attachment; filename="2.patch"

tree 84d7122001b844a79051505ecce03e2d246d6944
parent c3be0c39c8df0a3354df713028088ac1f5b0a780
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138888350 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138888350 -0200

[DCCP]: Fix error handling in dccp_init

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 proto.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 65b11ea..568d266 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -799,6 +799,7 @@ static int __init dccp_init(void)
 	if (rc)
 		goto out;
 
+	rc = -ENOBUFS;
 	dccp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("dccp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
@@ -866,7 +867,8 @@ static int __init dccp_init(void)
 		INIT_HLIST_HEAD(&dccp_hashinfo.bhash[i].chain);
 	}
 
-	if (init_dccp_v4_mibs())
+	rc = init_dccp_v4_mibs();
+	if (rc)
 		goto out_free_dccp_bhash;
 
 	rc = -EAGAIN;


------=_Part_11446_2002684.1139020682871--
