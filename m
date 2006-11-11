From: James Morris <jmorris@namei.org>
Date: Sat, 11 Nov 2006 18:03:47 +0000
Subject: RE: [PATCH RFC] SELinux support for DCCP
Message-Id: <XMMS.LNX.4.64.0611111302030.30219@d.namei>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sat, 11 Nov 2006, Joshua Brindle wrote:

> > From: James Morris [mailto:jmorris@namei.org] 
> > 
> > On Sat, 11 Nov 2006, Joshua Brindle wrote:
> > 
> > > James Morris wrote:
> > > > The kernel patch is included below, please review.
> > > > 
> > > > Signed-off-by: James Morris <jmorris@namei.org>
> > > >   +#define CONTEXT__TRANSLATE                        0x00000001UL
> > > > +#define CONTEXT__CONTAINS                         0x00000002UL
> > > >   +   S_(SECCLASS_CONTEXT, CONTEXT__TRANSLATE, "translate")
> > > > +   S_(SECCLASS_CONTEXT, CONTEXT__CONTAINS, "contains")
> > > >   +    S_("context")
> > > >   +#define SECCLASS_CONTEXT                                 59
> > > >   
> > > 
> > > oops?
> > 
> > What?
> > 
> 
> Did you mean to include context classes as part of the dccp patch?

The kernel headers have to match the flask headers in the userland tools, 
as they share policy-related data structures.  Ideally, we'd have security 
server namespaces, to keep these things separate.


- James
-- 
James Morris
<jmorris@namei.org>
