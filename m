From: Paul Moore <paul.moore@hp.com>
Date: Mon, 13 Nov 2006 20:54:13 +0000
Subject: Re: [PATCH RFC] SELinux support for DCCP
Message-Id: <4558DB75.9020608@hp.com>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Paul Moore wrote:
 > Based on my simple understanding of DCCP it looks okay to me, i.e. all the
> relevant things we do for TCP seem to be done now for DCCP.  Also, I don't think
> adding labeled networking support should be all that difficult; basically we
> would need to do the following (can anyone think of anything else?):
> 
> 1. Add the security_inet_conn_established() hook to the DCCP code path (if it
> isn't there already, need to check) so that the last part of the DCCP handshake
> is caught by the LSM.

Sorry, forgot to mention that we would also need to check the other related LSM
connection based hooks like inet_conn_request() and inet_csk_clone().

-- 
paul moore
linux security @ hp
