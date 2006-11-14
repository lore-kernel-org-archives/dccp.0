From: David Miller <davem@davemloft.net>
Date: Tue, 14 Nov 2006 00:49:09 +0000
Subject: Re: [PATCH] dccp: remove module exit functions
Message-Id: <20061113.164909.35016870.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
In-Reply-To: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 10 Nov 2006 16:32:16 -0200

> On 11/10/06, James Morris <jmorris@namei.org> wrote:
> > On Fri, 10 Nov 2006, James Morris wrote:
> >
> > > I wonder if this facility can be integrated more generally into the kernel
> > > protocol which people are developing.
> >
> > Ugh, editor screwup.  That was meant to be
> >
> > I wonder if this facility can be integrated more generally into the kernel
> > as a kernel hacking option, as this is not the only protocol which people
> > are developing.
> >
> 
> See:
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09a_release_ctl_socket_at_exit.diff
> 
> This one requires a bit more thinking, so I'm postponing it for now to
> get the simple bits in Gerrit's patch queue cherrypicked and sent for
> Dave.

One possible way to handle this is to flag certain sockets such that
no refrence counting is done for them against the module.  It is
an indication that the module will take care of such sockets on
cleanup.

It seems that this would limit the cost to a test at socket create
and destroy time.
