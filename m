From: James Morris <jmorris@namei.org>
Date: Mon, 13 Nov 2006 21:18:42 +0000
Subject: Re: [PATCH RFC] SELinux support for DCCP
Message-Id: <XMMS.LNX.4.64.0611131615470.9597@d.namei>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, 13 Nov 2006, Paul Moore wrote:

> Based on my simple understanding of DCCP it looks okay to me, i.e. all the
> relevant things we do for TCP seem to be done now for DCCP.  Also, I don't think
> adding labeled networking support should be all that difficult; basically we
> would need to do the following (can anyone think of anything else?):
> 
> 1. Add the security_inet_conn_established() hook to the DCCP code path (if it
> isn't there already, need to check) so that the last part of the DCCP handshake
> is caught by the LSM.
> 2. Add the DCCP socket class to the SELinux NetLabel code.

Yep, it should be identical to TCP in the simplest case.  It may be 
possible to label services within a connection (kind of like substreams), 
but it'd need to be supported by xfrm and IPsec first.



- James
-- 
James Morris
<jmorris@namei.org>
