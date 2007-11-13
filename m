From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Tue, 13 Nov 2007 16:51:30 +0000
Subject: Re: How much is available for reading on the socket?
Message-Id: <5bc4c4570711130851p2b94a284iba13cef665d083ec@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
In-Reply-To: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/11/9, Arnaldo Carvalho de Melo <acme@redhat.com>:
> Em Fri, Nov 09, 2007 at 01:51:27PM +0000, Gerrit Renker escreveu:
> > | > using "ioctl (socket, FIONREAD, &readsize)" I can get how much is
> > | > available to read from the socket using TCP. Is there a equivalent
> > | > option for DCCP?
> > |
> > | Looks like dccp_ioctl() happily returns -ENOIOCTLCMD (for now). If you
> > | have IO and memory to waste, you can always recv(..., MSG_PEEK) to work
> > | around this.
> > |
> > Arnaldo wrote a patch which realises SIOCINQ (it is in 2.6.24-rc1/2).
>
> And, on Linux:
>
> include/linux/sockios.h
>
> /* Linux-specific socket ioctls */
> #define SIOCINQ         FIONREAD
>
> - Arnaldo
>

And I'm using this on the gstreamer plugin and it is working ok.

Leandro.
