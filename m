From: "Patrick Andrieux" <patrick.andrieux@gmail.com>
Date: Mon, 11 Jun 2007 18:36:41 +0000
Subject: Re: [PATCH] Kprobes i386 fix for mark ro data
Message-Id: <fca78b970706111136q46ffce7cs1b9a49d7b351d281@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070607042229.GA9350@in.ibm.com>
In-Reply-To: <20070607042229.GA9350@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

This patch fixed my problem. I re-enabled CONFIG_DEBUG_RODATA and I
don't have seg fault with or without your DCCP patches. Inserting
`dccp_probe` or `tcp_probe`module doesn't cause any troubles.

Patrick.


On 10/06/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 6/7/07, S. P. Prasanna <prasanna@in.ibm.com> wrote:
> > > >It faulted when it tried to write the breakpoint instruction into the
> > > >running kernel's executable code. Apparently the kernel code is now marked
> > > >read-only?
> > > >
> > > >
> > > Yes it would appear to be the case as user has CONFIG_DEBUG_RODATA
> > > set. Patrick - can you turn this off and retest? It's under Kernel
> > > Hacking, Write protect kernel read only data structures.
> > >
> >
> > Ian,
> >
> > Please find the fix as suggested by Andi Kleen
> > for the above stated problem.
> >
> > Thanks
> > Prasanna
> >
> >
> I went to test the fix and first of all went to replicate the problem.
> My build has CONFIG_DEBUG_RODATA set but the problem does not occur
> without the patch. Should I be concerned about this and raise a bug
> for that as I would think that means there is a problem that the read
> only protection isn't working (this is off Linus' tree synced
> tonight).
>
> Patrick - can you test whether this patch fixes your problem? You said
> disabling CONFIG_DEBUG_RODATA fixed your problem but can you try
> re-enabling and testing this patch?
>
> Ian
> --
> Web: http://wand.net.nz/~iam4/
> Blog: http://iansblog.jandi.co.nz
> WAND Network Research Group
>
