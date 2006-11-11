From: James Morris <jmorris@namei.org>
Date: Sat, 11 Nov 2006 17:46:29 +0000
Subject: Re: [PATCH RFC] SELinux support for DCCP
Message-Id: <XMMS.LNX.4.64.0611111245380.29096@d.namei>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sat, 11 Nov 2006, Eric Paris wrote:

> > +#define SECCLASS_CONTEXT                                 59
> > +#define SECCLASS_DCCP_SOCKET                             60
> 
> 
> What are the SECCLASS_CONTEXT, CONTEXT__CONTAINS, and CONTEXT__TRANSLATE
> changes?

The kernel headers have to match the userspace headers.  This context 
stuff is from userland.



-- 
James Morris
<jmorris@namei.org>
