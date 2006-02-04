From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:38:44 +0000
Subject: [PATCH 8/11][DCCP] ackvec: Delete all the ack vector records in dccp_ackvec_free
Message-Id: <39e6f6c70602031838g3ca098b9qe5e441b0ef1c95e6@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11486_31074784.1139020724333"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11486_31074784.1139020724333
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11486_31074784.1139020724333
Content-Type: text/x-patch; name=8.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9bd8qm
Content-Disposition: attachment; filename="8.patch"

tree 39d2dec525df09a590e0d9ad162d734f3344e26d
parent 90753caf01c1a27cf3fd18f0e71c77db268856d3
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138987721 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138987721 -0200

[DCCP] ackvec: Delete all the ack vector records in dccp_ackvec_free

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 2a82acc..08b1b08 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -159,7 +159,17 @@ void dccp_ackvec_free(struct dccp_ackvec
 {
 	if (unlikely(av == NULL))
 		return;
-	WARN_ON(!list_empty(&av->dccpav_records));
+
+	if (!list_empty(&av->dccpav_records)) {
+		struct dccp_ackvec_record *avr, *next;
+
+		list_for_each_entry_safe(avr, next, &av->dccpav_records,
+					 dccpavr_node) {
+			list_del_init(&avr->dccpavr_node);
+			dccp_ackvec_record_delete(avr);
+		}
+	}
+
 	kmem_cache_free(dccp_ackvec_slab, av);
 }
 


------=_Part_11486_31074784.1139020724333--
