From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 10 Jun 2007 06:24:15 +0000
Subject: Re: [PATCH] Kprobes i386 fix for mark ro data
Message-Id: <5640c7e00706092324kd0ea8e0pef4a4cd764fce5d3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070607042229.GA9350@in.ibm.com>
In-Reply-To: <20070607042229.GA9350@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/7/07, S. P. Prasanna <prasanna@in.ibm.com> wrote:
> > >It faulted when it tried to write the breakpoint instruction into the
> > >running kernel's executable code. Apparently the kernel code is now marked
> > >read-only?
> > >
> > >
> > Yes it would appear to be the case as user has CONFIG_DEBUG_RODATA
> > set. Patrick - can you turn this off and retest? It's under Kernel
> > Hacking, Write protect kernel read only data structures.
> >
>
> Ian,
>
> Please find the fix as suggested by Andi Kleen
> for the above stated problem.
>
> Thanks
> Prasanna
>
>
I went to test the fix and first of all went to replicate the problem.
My build has CONFIG_DEBUG_RODATA set but the problem does not occur
without the patch. Should I be concerned about this and raise a bug
for that as I would think that means there is a problem that the read
only protection isn't working (this is off Linus' tree synced
tonight).

Patrick - can you test whether this patch fixes your problem? You said
disabling CONFIG_DEBUG_RODATA fixed your problem but can you try
re-enabling and testing this patch?

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
