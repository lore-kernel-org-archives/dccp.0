From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Feb 2010 06:16:56 +0000
Subject: Re: [PATCH v2 1/1] dccp: fix auto-loading of dccp(_probe)
Message-Id: <20100203061656.GA5415@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Neil,

I have tested your patch, it works fine thanks to the repeated execution of the macro
argument. I have reformatted it, removing the inner parentheses, which I think is
justified since macros copy their arguments in full. Also converted your email to a
drafted commit message. Due to this, have not copied your signed-off -- if you are
ok, please add, this should be submitted asap.

>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: fix loading of dccp_probe

This fixes commit (38ff3e6bb987ec583268da8eb22628293095d43b) ("dccp_probe:
Fix module load dependencies between dccp and dccp_probe", from 15 Jan).

It fixes the construction of the first argument of try_then_request_module(),
where only valid return codes from the first argument should be returned.

What we do now is assign the result of register_jprobe() to ret, without
the side effect of the comparison.

Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/probe.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -161,8 +161,8 @@ static __init int dccpprobe_init(void)
 	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
 		goto err0;
 
-	ret = try_then_request_module((register_jprobe(&dccp_send_probe) = 0),
-					"dccp");
+	try_then_request_module((ret = register_jprobe(&dccp_send_probe)) = 0,
+				"dccp");
 	if (ret)
 		goto err1;
 
