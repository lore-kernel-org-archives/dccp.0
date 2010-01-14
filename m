From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 14 Jan 2010 20:15:17 +0000
Subject: [PATCH] dccp_probe: Fix module load dependencies between dccp and
Message-Id: <20100114201517.GA32352@hmsreliant.think-freely.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hey-
	This was just recently reported to me.  When built as modules,
the dccp_probe module has a silent dependency on the dccp module.  This stems
from the fact that the module_init routine of dccp_probe registers a jprobe on
the dccp_sendmsg symbol.  Since the symbol is only referenced as a text string
(the .symbol_name field in the jprobe struct) rather than the address of the
symbol itself, depmod never picks this dependency up, and so if you load the
dccp_probe module without the dccp module loaded, the register_jprobe call fails
with an -EINVAL, and the whole module load fails.

	The fix is pretty easy, we can just wrap the register_jprobe call in a
try_then_request_module call, which forces the dependency to get satisfied prior
to the probe registration.

	I've verified that this fixes the problem myself.

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 probe.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)


diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index a1362dc..bace1d8 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -161,7 +161,8 @@ static __init int dccpprobe_init(void)
 	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
 		goto err0;
 
-	ret = register_jprobe(&dccp_send_probe);
+	ret = try_then_request_module((register_jprobe(&dccp_send_probe) = 0),
+					"dccp");
 	if (ret)
 		goto err1;
 
