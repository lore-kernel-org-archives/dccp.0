From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:38:23 +0000
Subject: [PATCH 5/11][LIST]: Introduce list_for_each_entry_from
Message-Id: <39e6f6c70602031838u586a8f03j944b4ea43c81788c@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11462_21320302.1139020703836"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11462_21320302.1139020703836
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11462_21320302.1139020703836
Content-Type: text/x-patch; name=5.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9bbgmb
Content-Disposition: attachment; filename="5.patch"

tree dd63ed037c6999ea5382a19b95bddd530d10a49f
parent f46cb510ee1e527b0d6b8a8c13a757c8355d08fd
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138971659 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138971659 -0200

[LIST]: Introduce list_for_each_entry_from

For iterating over list of given type continuing from existing point.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 list.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

------------------------------------------------------------------------------

diff --git a/include/linux/list.h b/include/linux/list.h
index dffc0fe..5bb5aab 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -409,6 +409,17 @@ static inline void list_splice_init(stru
 	     pos = list_entry(pos->member.next, typeof(*pos), member))
 
 /**
+ * list_for_each_entry_from -	iterate over list of given type
+ *			continuing from existing point
+ * @pos:	the type * to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_from(pos, head, member) 			\
+	for (; prefetch(pos->member.next), &pos->member != (head);	\
+	     pos = list_entry(pos->member.next, typeof(*pos), member))
+
+/**
  * list_for_each_entry_safe - iterate over list of given type safe against removal of list entry
  * @pos:	the type * to use as a loop counter.
  * @n:		another type * to use as temporary storage

------=_Part_11462_21320302.1139020703836--
