From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Feb 2010 06:09:29 +0000
Subject: dccp-test-tree [Patch 1/1] "UDP-like" CCID sample kernel module
Message-Id: <20100215060928.GA5350@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch is for the dccp test tree at 
 git://eden-feed.erg.abdn.ac.uk/dccp_exp [subtree 'dccp']

The actual 'module' is only 5 lines long.
>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: sample kernel module, NULL-CCID ("UDP-like")

This implements an experimental CCID which does not do any congestion control,
i.e. "UDP-like".

This is an experimental CCID. It is not meant for actual deployment, but
rather as sample kernel code, providing a worked example of how to add a
new CCID module.

Since CCID-0 is reserved (RFC 4340, table 5), this experimental NULL CCID uses
the first available experimental CCID, CCID-248 (RFC 4340, 19.5).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h   |    7 +++++++
 net/dccp/Makefile      |    1 +
 net/dccp/ccid.c        |    3 +++
 net/dccp/ccid.h        |    3 +++
 net/dccp/ccids/Kconfig |   12 ++++++++++++
 net/dccp/ccids/ccid0.c |   27 +++++++++++++++++++++++++++
 net/dccp/feat.c        |   17 ++++++++++++++++-
 7 files changed, 69 insertions(+), 1 deletion(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -177,6 +177,13 @@ enum {
 enum {
 	DCCPC_CCID2 = 2,
 	DCCPC_CCID3 = 3,
+	/*
+	 * CCIDs 248-255 below are permanently reserved for
+	 * experimental and testing use (RFC 4340, 19.5).
+	 */
+#define DCCPC_TESTING_MIN	248
+#define DCCPC_TESTING_MAX	255
+	DCCPC_CCID_ZERO = DCCPC_TESTING_MIN,
 };
 
 /* DCCP features (RFC 4340 section 6.4) */
--- /dev/null
+++ b/net/dccp/ccids/ccid0.c
@@ -0,0 +1,27 @@
+/*
+ *  CCID-ZERO - UDP-like congestion control
+ *
+ *  This is a sample kernel module, used for testing and development, but not
+ *  for actual deployment. The CCID number is taken from the range of CCIDs
+ *  set apart for testing and experimenting.
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include "../ccid.h"
+
+struct ccid_operations ccid0_ops = {
+	.ccid_id	= DCCPC_CCID_ZERO,
+	.ccid_name	= "UDP-like transport"
+};
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -19,6 +19,9 @@ static struct ccid_operations *ccids[]  #ifdef CONFIG_IP_DCCP_CCID3
 	&ccid3_ops,
 #endif
+#ifdef CONFIG_IP_DCCP_CCID0
+	&ccid0_ops,
+#endif
 };
 
 static struct ccid_operations *ccid_by_number(const u8 id)
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -91,6 +91,9 @@ struct ccid_operations {
 						 int __user *optlen);
 };
 
+#ifdef CONFIG_IP_DCCP_CCID0
+extern struct ccid_operations ccid0_ops;
+#endif
 extern struct ccid_operations ccid2_ops;
 #ifdef CONFIG_IP_DCCP_CCID3
 extern struct ccid_operations ccid3_ops;
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -620,7 +620,8 @@ static u8 dccp_feat_is_valid_sp_val(u8 f
 {
 	switch (feat_num) {
 	case DCCPF_CCID:
-		return val = DCCPC_CCID2 || val = DCCPC_CCID3;
+		return	val = DCCPC_CCID2 || val = DCCPC_CCID3 ||
+			(val >= DCCPC_TESTING_MIN && val <= DCCPC_TESTING_MAX);
 	/* Type-check Boolean feature values: */
 	case DCCPF_SHORT_SEQNOS:
 	case DCCPF_ECN_INCAPABLE:
@@ -831,6 +832,18 @@ EXPORT_SYMBOL_GPL(dccp_feat_signal_nn_ch
  */
 static const struct ccid_dependency *dccp_feat_ccid_deps(u8 ccid, bool is_local)
 {
+	static const struct ccid_dependency ccid0_dependencies[2][2] = {
+		/*
+		 * The UDP-like CCID does not have special dependencies, but for
+		 * testing dependencies (e.g. Ack Vectors) can be defined below.
+		 */
+		{
+			{ 0, 0, 0, 0 }
+		},
+		{
+			{ 0, 0, 0, 0 }
+		}
+	};
 	static const struct ccid_dependency ccid2_dependencies[2][2] = {
 		/*
 		 * CCID2 mandates Ack Vectors (RFC 4341, 4.): as CCID is a TX
@@ -916,6 +929,8 @@ static const struct ccid_dependency *dcc
 		}
 	};
 	switch (ccid) {
+	case DCCPC_CCID_ZERO:
+		return ccid0_dependencies[is_local];
 	case DCCPC_CCID2:
 		return ccid2_dependencies[is_local];
 	case DCCPC_CCID3:
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -103,4 +103,16 @@ config IP_DCCP_TFRC_LIB
 
 config IP_DCCP_TFRC_DEBUG
 	def_bool y if IP_DCCP_CCID3_DEBUG
+
+config IP_DCCP_CCID0
+	bool "CCID-ZERO (UDP-Like) sample kernel module"
+	def_bool n
+	---help---
+	  This is a sample kernel module to illustrate the integration of new
+	  CCID kernel modules into CCID. It can also be used for performance
+	  testing, but is not meant for deployment since it operates without
+	  any congestion control. It is a NULL CCID, its identifier is 248.
+
+	  Say N.
+
 endmenu
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -7,6 +7,7 @@ dccp-y := ccid.o feat.o input.o minisock
 #
 # CCID-2 is default (RFC 4340, p. 77) and has Ack Vectors as dependency
 dccp-y += ccids/ccid2.o ackvec.o
+dccp-$(CONFIG_IP_DCCP_CCID0)	+= ccids/ccid0.o
 dccp-$(CONFIG_IP_DCCP_CCID3)	+= ccids/ccid3.o
 dccp-$(CONFIG_IP_DCCP_TFRC_LIB) += ccids/lib/tfrc.o		\
 				   ccids/lib/tfrc_equation.o	\
