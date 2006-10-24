From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 13:59:36 +0000
Subject: [PATCH 5/17] [DCCPv6]: Resolve conditional build problem
Message-Id: <200610241459.37050@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCPv6]: Resolve conditional build problem

Resolves the problem that if IPv6 was configured `y' and DCCP `m' then
dccp_ipv6 was not built as a module. With this change, dccp_ipv6 is built
as a module whenever DCCP *OR* IPv6 are configured as modules; it will be
built-in only if both DCCP = `y' and IPV6 = `y'.


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/Makefile |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index 17ed99c..f4f8793 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,13 +1,13 @@
-obj-$(CONFIG_IPV6) += dccp_ipv6.o
-
-dccp_ipv6-y := ipv6.o
-
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
 dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o
 
 dccp_ipv4-y := ipv4.o
 
+# build dccp_ipv6 as module whenever either IPv6 or DCCP is a module
+obj-$(subst y,$(CONFIG_IP_DCCP),$(CONFIG_IPV6)) += dccp_ipv6.o
+dccp_ipv6-y := ipv6.o
+
 dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.o
 
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o

