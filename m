From: "Leandro Melo de Sales" <leandroal@gmail.com>
Date: Tue, 06 Mar 2007 21:36:14 +0000
Subject: Re: User API and Additional Features
Message-Id: <5bc4c4570703061336h63ca1951i735361a3e0c6adfe@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570702221025yd6903b0n59a2d916c227c4af@mail.gmail.com>
In-Reply-To: <5bc4c4570702221025yd6903b0n59a2d916c227c4af@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Patrick,

    Good! I'm currently talking to Ian about how to define a good
userspace API for DCCP. In fact, we can join all of the efforts on it,
as you suggested, instend of working in a isolated manner. The initial
idea is to study and evalute this paper
http://www.cs.ucla.edu/~kohler/pubs/lai04efficiency.pdf as suggested
by Ian. My additional suggestion is to watch
http://www.infoq.com/presentations/effective-api-design video from
Joshua, which explain how to design a dood API and why it matters.
    In summary, me and Ian are trying to define a group of developers
to work on it. There is also Perry Lorier, who gave to as some ideas
to define the DCCP user API using Glibc. Do you have any other
comments? Particularly, I'm redirect my master proposal in the
implementation of DCCP Generalized Connection and can include stuffs
related to userspace API for DCCP too. So, the initial phase, in my
opinion, is to search a related works done, even if it is not directly
specific for DCCP, but we can learn with other experiences. Other
interesting paper is
http://user.informatik.uni-goettingen.de/~mobiarch/2006/MobiArch06_Lars.pdf
(Towards More Expressive Transport Layer).

[]s
Leandro

2007/3/6, patrick andrieux <patrick.andrieux@gmail.com>:
> Hi,
>
> Since I try to retrieve some DCCP features, I'm interested in the
> developement of an user API . Do you already have any plan for that ?
> it would make more sense if we followed the same way.
> I just installed 2.6.20-1 kernel with all DCCP patches from Ian's
> website and I'm figuring out how to use getsockopt() to get TFRC info
> struct.. Unfortunatly, i've got errno error when I do that, saying
> "Protocol not available". By looking at the source code, these
> features seems to be implemented, so i don't know yet where/what is my
> problem. Did you try to do this Leandro (or anyone else) ?
> I was thinking as well to use ioctl() call to get info from DCCP, but
> I didn't use that much ioctl() for now.
>
> rgds,
> Patrick.
>
>
> 2007/2/26, Leandro Melo de Sales <leandroal@gmail.com>:
> >  Ok Ian, I think the first this need a more dedicated research in order
> > to accomplish this DCCP User API. I'm taking my master degree on it,
> > so I'm going to looking for related works and try to adequate the
> >  works on it. Do you know if there are someone working on related
> > stuffs?
> >    I actually initiate the Generalized Connection implementation job.
> > I already modify the Kconfig files and Makefiles of the kernel to
> >  initiate the implementation. I'm currently studying dccp
> > implementation code and some kernel development docs, include the
> > paper that you put in your homepage and the book from Robert Love
> > (Novell Press).
> >
> > []s
> > Leandro
> >
> > --
> > Leandro Melo de Sales.
> > Computer Science MSc Candidate
> > Pervasive Computing Lab - embedded.ufcg.edu.br
> > Center of Electrical Engineering and Informatics at Federal University
> > of Campina Grande - UFCG / Brazil
> > 083 33101404 (extension 208)
> >
> > > 2007/2/22, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> > > > On 2/23/07, Leandro Melo de Sales < leandroal@gmail.com> wrote:
> > > > > Hi list,
> > > > >
> > > > >    I'm currently on the implementation of DCCP Generalized Connection
> > > > > draft (still studying codes, docs, etc.) as I already talked to
> > > > > Arnaldo and Eddie, but I already realized that in order to implement
> > > > > it we will need a more specific user API to permit users to switch
> > > > > between DCCP connections. Something more than just setsockopt, for
> > > > > instance. So I ask: is there any affort in define/decide a DCCP
> > > > > specific API which can externalize dccp specific features to the user?
> > > > > Another example, from the master tesis of Marie Camier ("Development
> > > > > of a Adaptative DCCP-Based Voip Client"), is the lack of specific
> > > > > methods to retrieve connection statistics and other stuffs, such as
> > > > > connection sequence numbers. Her solution was to retriave these
> > > > > information directly in the socket, through ioctl() system call.
> > > > >    Please let me know if I said something *out-of-date*.
> > > > >
> > > > > Thank you,
> > > > >
> > > > > []s
> > > > > Leandro
> > > > > -
> > > > Leandro,
> > > >
> > > > If you're looking to implement that it is great. There is certainly
> > > > nothing like that at present.
> > > >
> > > > Have a look at netlink as well to see if it suits the purpose as that
> > > > is becoming the most frequent way to get info out of the kernel for
> > > > networking.
> > > >
> > > > Ian
> > > > --
> > > > Web: http://wand.net.nz/~iam4
> > > > Blog: http://iansblog.jandi.co.nz
> > > > WAND Network Research Group
> > > >
> > >
> > -
> > To unsubscribe from this list: send the line "unsubscribe dccp" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at   http://vger.kernel.org/majordomo-info.html
> >
>
