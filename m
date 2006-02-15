From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 15 Feb 2006 11:49:06 +0000
Subject: [PATCH 1/1][DCCP]: Set the default CCID according to kernel config selection
Message-Id: <39e6f6c70602150349s3c467119m8edfbe567e7fd3cd@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_3599_11510431.1140004146423"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_3599_11510431.1140004146423
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_3599_11510431.1140004146423
Content-Type: text/x-patch; name=1.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ejpkzoo1
Content-Disposition: attachment; filename="1.patch"

tree d72a8934d54b685a72b7048d6aeb52f5ee6189ab
parent 5d993b3c9996d8df5a83a2d0f7e056b8963d7ee1
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1140003702 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1140003702 -0200

[DCCP]: Set the default CCID according to kernel config selection

Now CCID2 is the default, as stated in the RFC drafts, but we allow
a config where just CCID3 is built, where CCID3 becomes the default.

Signed-off-by: Ian McDonald <imcdnzl@gmail.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 dccp.h |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index f91c8a6..a70d1a2 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -329,9 +329,18 @@ static inline unsigned int dccp_hdr_len(
 
 /* initial values for each feature */
 #define DCCPF_INITIAL_SEQUENCE_WINDOW		100
-#define DCCPF_INITIAL_CCID			2
 #define DCCPF_INITIAL_ACK_RATIO			2
+
+#if defined(CONFIG_IP_DCCP_CCID2) || defined(CONFIG_IP_DCCP_CCID2_MODULE)
+#define DCCPF_INITIAL_CCID			2
 #define DCCPF_INITIAL_SEND_ACK_VECTOR		1
+#elif defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
+#define DCCPF_INITIAL_CCID			3
+#define DCCPF_INITIAL_SEND_ACK_VECTOR		0
+#else
+#error  "At least one CCID must be built as the default"
+#endif
+
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
 

------=_Part_3599_11510431.1140004146423--
