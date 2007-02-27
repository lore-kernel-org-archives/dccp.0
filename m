From: "patrick andrieux" <patrick.andrieux@gmail.com>
Date: Tue, 27 Feb 2007 10:59:03 +0000
Subject: Re: [dccp] DCCP and iotcl
Message-Id: <fca78b970702270259j4973f569nf09532d4734a2fe@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00702211258k2f538efbqb590dae857cd6083@mail.gmail.com>
In-Reply-To: <5640c7e00702211258k2f538efbqb590dae857cd6083@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

I'm following your recommandation, and installing 2.6.20. I'm doing it
on virtual machine (user mode linux) in order to keep my own kernel
safe.

Thanks for your tips Ian. My purpose is to get a few information from
dccp, anything usefull in order to know the network's congestion. And
based on that, I'll modified dynamically codec properties suchh as
bitrate/quality/...  to decrease/increase the packets size.

rgds, Patrick.


2007/2/22, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> Patrick,
>
> I would recommend using 2.6.20 and applying the patches from my
> website or Gerrit's website. Then CCID3 behaves fairly well. If you
> are mainly planning to use CCID2 then 2.6.20 as is should be fine and
> I think 2.6.19 as well but either way you need to upgrade from 2.6.18.
>
> I've put a few more tips on my DCCP page at my webpage (in footer) and
> also some updated sample code. It is in the middle of another
> application of mine but you should be able to work it out. I'm not
> sure if that other code still works or not and don't have time to
> test/fix right now.
>
> As always I'm interested to hear what purpose people are using DCCP
> for so if you'd like to share that too it would be great.
>
> Ian
>
> On 2/23/07, patrick andrieux <patrick.andrieux@gmail.com> wrote:
> > Hi and thanks Ian,
> >
> > I'm using the simple client/server application :
> > http://wand.net.nz/~iam4/dccp/dccp-cs-0.01.tar.bz2
> > I work on Debian etch with default linux kernel which is 2.6.18 for now.
> >
> > I hadn't apply any patches yet, but I'm doing it today...
> > I patched dccp module with patches 1 to 6 with a similar command than below
> > Unfortunately, the 7th (07-2b_ccid3_tx-len-not-needed.diff) doesn't work :
> >   /usr/src/linux-source-2.6.18# patch -p1 <
> > /tmp/patchDCCP/07-2b_ccid3_tx- len-not-needed.diff
> >   patching file net/dccp/ccids/ccid3.c
> >   Hunk #1 FAILED at 149.
> >   1 out of 1 hunk FAILED -- saving rejects to file net/dccp/ccids/ccid3.c.rej
> >
> > Am I doing something wrong ? or is there any issues with this patch ?
> > (and I guess the errors I get when I try the other patches come from
> > this first problem)
> >
> > regards,
> > Patrick.
> >
> >
> >  2007/2/21, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> > >    On 2/22/07, patrick andrieux <patrick.andrieux@gmail.com> wrote:
> > > > Hi,
> > > >
> > > > I'm doing some research on DCCP, and I'm trying to use ioctl() function.
> > > > I ran the sample code (from
> > > > http://linux-net.osdl.org/index.php/DCCP_Testing  ) using
> > > > -proto TCP. I added a few lines to use ioctl(), and it works with TCP
> > > > (return value is 0).
> > >
> > > Which sample code are you using? What version of Linux? Any extra patches?
> > > >
> > > > But it doesn't work with DCCP, I get -1 as return value.
> > > > I took a look at DCCP source code, and basically my first step would be to
> > > > display in the kernel log what dccp_ioctl() prints. My guess is that
> > > > functionalities to use ioctl() are not implemented yet. am I right ?
> > > > Is there any way to get some information from DCCP other than sysctl ?
> > > >
> > > Yes - use dccp_probe. It's in the source code tree and also on the
> > > Wiki you were looking at.
> > >
> > > cc'd   dccp@vger.kernel.org as this is where we can discuss more (as per Leandro)
> > >
> > > Ian
> > > --
> > > Web: http://wand.net.nz/~iam4
> > > Blog:   http://iansblog.jandi.co.nz
> > > WAND Network Research Group
> > >
> > -
> > To unsubscribe from this list: send the line "unsubscribe dccp" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>
>
> --
> Web: http://wand.net.nz/~iam4
> Blog: http://iansblog.jandi.co.nz
> WAND Network Research Group
>
