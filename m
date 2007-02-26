From: "Leandro Melo de Sales" <leandroal@gmail.com>
Date: Mon, 26 Feb 2007 09:31:25 +0000
Subject: Re: User API and Additional Features
Message-Id: <5bc4c4570702260131pe4764eeide1905b6f8bc78b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570702221025yd6903b0n59a2d916c227c4af@mail.gmail.com>
In-Reply-To: <5bc4c4570702221025yd6903b0n59a2d916c227c4af@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ok Ian, I think the first this need a more dedicated research in order
to accomplish this DCCP User API. I'm taking my master degree on it,
so I'm going to looking for related works and try to adequate the
works on it. Do you know if there are someone working on related
stuffs?
   I actually initiate the Generalized Connection implementation job.
I already modify the Kconfig files and Makefiles of the kernel to
initiate the implementation. I'm currently studying dccp
implementation code and some kernel development docs, include the
paper that you put in your homepage and the book from Robert Love
(Novell Press).

[]s
Leandro

--
Leandro Melo de Sales.
Computer Science MSc Candidate
Pervasive Computing Lab - embedded.ufcg.edu.br
Center of Electrical Engineering and Informatics at Federal University
of Campina Grande - UFCG / Brazil
083 33101404 (extension 208)

> 2007/2/22, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> > On 2/23/07, Leandro Melo de Sales <leandroal@gmail.com> wrote:
> > > Hi list,
> > >
> > >    I'm currently on the implementation of DCCP Generalized Connection
> > > draft (still studying codes, docs, etc.) as I already talked to
> > > Arnaldo and Eddie, but I already realized that in order to implement
> > > it we will need a more specific user API to permit users to switch
> > > between DCCP connections. Something more than just setsockopt, for
> > > instance. So I ask: is there any affort in define/decide a DCCP
> > > specific API which can externalize dccp specific features to the user?
> > > Another example, from the master tesis of Marie Camier ("Development
> > > of a Adaptative DCCP-Based Voip Client"), is the lack of specific
> > > methods to retrieve connection statistics and other stuffs, such as
> > > connection sequence numbers. Her solution was to retriave these
> > > information directly in the socket, through ioctl() system call.
> > >    Please let me know if I said something *out-of-date*.
> > >
> > > Thank you,
> > >
> > > []s
> > > Leandro
> > > -
> > Leandro,
> >
> > If you're looking to implement that it is great. There is certainly
> > nothing like that at present.
> >
> > Have a look at netlink as well to see if it suits the purpose as that
> > is becoming the most frequent way to get info out of the kernel for
> > networking.
> >
> > Ian
> > --
> > Web: http://wand.net.nz/~iam4
> > Blog: http://iansblog.jandi.co.nz
> > WAND Network Research Group
> >
>
