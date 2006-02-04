From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:38:18 +0000
Subject: [PATCH 4/11][LIST]: Introduce list_for_each_entry_safe_from
Message-Id: <39e6f6c70602031838m19f76817p42c366c5493e9966@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11458_7959400.1139020698434"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11458_7959400.1139020698434
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11458_7959400.1139020698434
Content-Type: text/x-patch; name=4.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9bb6hn
Content-Disposition: attachment; filename="4.patch"

tree 90c345002f9b2c485b64c2b53582fb848eabbc4d
parent ec01d0836f8e4405ef0281590c296180a08f21c3
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138911314 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138911314 -0200

[LIST]: Introduce list_for_each_entry_safe_from

For iterate over list of given type from existing point safe against removal of
list entry.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 list.h |   13 +++++++++++++
 1 file changed, 13 insertions(+)

------------------------------------------------------------------------------

diff --git a/include/linux/list.h b/include/linux/list.h
index 945daa1..dffc0fe 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -436,6 +436,19 @@ static inline void list_splice_init(stru
 	     pos = n, n = list_entry(n->member.next, typeof(*n), member))
 
 /**
+ * list_for_each_entry_safe_from - iterate over list of given type
+ *			from existing point safe against removal of list entry
+ * @pos:	the type * to use as a loop counter.
+ * @n:		another type * to use as temporary storage
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_safe_from(pos, n, head, member) 			\
+	for (n = list_entry(pos->member.next, typeof(*pos), member);		\
+	     &pos->member != (head);						\
+	     pos = n, n = list_entry(n->member.next, typeof(*n), member))
+
+/**
  * list_for_each_entry_safe_reverse - iterate backwards over list of given type safe against
  *				      removal of list entry
  * @pos:	the type * to use as a loop counter.

------=_Part_11458_7959400.1139020698434--
