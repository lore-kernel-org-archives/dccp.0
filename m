From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 08 Jun 2008 15:53:01 +0000
Subject: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace through procfs
Message-Id: <20080608155834.E0A99BD22@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Since packets with invalid cmsg parameters can be rejected by kernel there
is a need to allow applications to access information on available policies
and their respective cmsg parameters at runtime. This patch simplifies
maintaining compatibility between userspace applications and DCCP code.
Information is available through files in /proc/net/dccp/qpolicies/

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 net/dccp/dccp.h    |    3 ++
 net/dccp/proto.c   |    6 +++++
 net/dccp/qpolicy.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index c6e1a9c..49931b6 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -224,6 +224,9 @@ extern void		dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb);
 extern struct sk_buff	*dccp_qpolicy_top(struct sock *sk);
 extern struct sk_buff	*dccp_qpolicy_pop(struct sock *sk);
 
+extern int 		dccp_qpolicy_init(void);
+extern void		dccp_qpolicy_exit(void);
+
 /*
  * TX Packet Output and TX Timers
  */
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index bdc4126..71cbe56 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1186,9 +1186,15 @@ static int __init dccp_init(void)
 	if (rc)
 		goto out_ackvec_exit;
 
+	rc = dccp_qpolicy_init();
+	if (rc)
+		goto out_qpolicy_exit;
+
 	dccp_timestamping_init();
 out:
 	return rc;
+out_qpolicy_exit:
+	dccp_qpolicy_exit();
 out_ackvec_exit:
 	dccp_ackvec_exit();
 out_free_dccp_mib:
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 4270c7f..3d1a095 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -10,6 +10,7 @@
  *  as published by the Free Software Foundation.
  */
 #include <asm/unaligned.h>
+#include <linux/proc_fs.h>
 #include "dccp.h"
 
 /*
@@ -125,3 +126,59 @@ struct sk_buff *dccp_qpolicy_pop(struct sock *sk)
 		skb_unlink(skb, &sk->sk_write_queue);
 	return skb;
 }
+
+int proc_read_qpolicy_params(char *page, char **start,
+				off_t off, int count,
+				int *eof, void *data)
+{
+	return sprintf(page, "%s\n", (char*)data);
+}
+
+static struct proc_dir_entry *qpolicies_dir;
+static struct proc_dir_entry *qpol_entries[2*DCCPQ_POLICY_MAX];
+static int entry_counter = 0;
+
+void add_qpol_info(int qpol_number, char* symlink, char* content)
+{
+	struct proc_dir_entry *qpol_file, *qpol_symlink;
+	char name[10];
+	sprintf(name, "%d", qpol_number);
+
+	qpol_file = create_proc_read_entry(name, 0444, qpolicies_dir,
+					proc_read_qpolicy_params, content);
+	if(qpol_file = NULL)
+		return;
+	qpol_file->owner = THIS_MODULE;
+	qpol_entries[entry_counter++] = qpol_file;
+
+	qpol_symlink = proc_symlink(symlink, qpolicies_dir, name);
+	if(qpol_symlink = NULL)
+		return;
+	qpol_symlink->owner = THIS_MODULE;
+	qpol_entries[entry_counter++] = qpol_symlink;
+}
+
+int dccp_qpolicy_init()
+{
+	char buffer[2048];
+	proc_mkdir("dccp", init_net.proc_net);
+	qpolicies_dir = proc_mkdir("dccp/qpolicies", init_net.proc_net);
+	if(qpolicies_dir = NULL)
+		return -ENOMEM;
+
+	add_qpol_info(DCCPQ_POLICY_SIMPLE, "simple", "");
+
+	sprintf(buffer, "%d priority\n", DCCP_SCM_PRIORITY);
+	add_qpol_info(DCCPQ_POLICY_PRIO, "prio", buffer);
+
+	return 0;
+}
+
+void dccp_qpolicy_exit()
+{
+	int i = 0;
+	for(i=0;i<entry_counter;i++)
+		remove_proc_entry(qpol_entries[i]->name, qpolicies_dir);
+	remove_proc_entry("dccp/qpolicies", init_net.proc_net);
+	entry_counter = 0;
+}
-- 
1.5.4.5

