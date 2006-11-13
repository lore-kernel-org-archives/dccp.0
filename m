From: Paul Moore <paul.moore@hp.com>
Date: Mon, 13 Nov 2006 20:44:43 +0000
Subject: Re: [PATCH RFC] SELinux support for DCCP
Message-Id: <4558D93B.9030003@hp.com>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

James Morris wrote:
> This patch implements SELinux kernel support for DCCP 
> (http://linux-net.osdl.org/index.php/DCCP), which is similar in operation 
> to TCP in terms of connected state between peers.
> 
> The SELinux support for DCCP is thus modeled on existing handling of TCP.
> 
> A new DCCP socket class is introduced, to allow protocol differentation.  
> The permissions for this class inherit all of the socket permissions, as 
> well as the current TCP permissions (node_bind, name_bind etc). IPv4 and 
> IPv6 are supported, although labeled networking is not, at this stage.
> 
> Patches for SELinux userspace are at:
> http://people.redhat.com/jmorris/selinux/dccp/user/
> 
> I've performed some basic testing, and it seems to be working as expected.  
> Adding policy support is similar to TCP, the only real difference being 
> that it's a different protocol.
> 
> The kernel patch is included below, please review.
> 
> Signed-off-by: James Morris <jmorris@namei.org>

Acked-by: Paul Moore <paul.moore@hp.com>

Based on my simple understanding of DCCP it looks okay to me, i.e. all the
relevant things we do for TCP seem to be done now for DCCP.  Also, I don't think
adding labeled networking support should be all that difficult; basically we
would need to do the following (can anyone think of anything else?):

1. Add the security_inet_conn_established() hook to the DCCP code path (if it
isn't there already, need to check) so that the last part of the DCCP handshake
is caught by the LSM.
2. Add the DCCP socket class to the SELinux NetLabel code.

The patch should be pretty small, in fact I'll volunteer to submit the code once
this patch makes it's way into the net-2.6.20 tree.

-- 
paul moore
linux security @ hp
