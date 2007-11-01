From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 04:13:54 +0000
Subject: Re: Gstreamer e DCCP: issues related to ccid-3
Message-Id: <5bc4c4570710312113r485b7869x2b5014a77421b959@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
In-Reply-To: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/10/25, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> On 10/25/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > /* something like (but do have a look at the paraslash sources)
> >     do {
> >         wrote = send (socket, (const char *) buf + bytes_written,
> >                              count - bytes_written, MSG_NOSIGNAL);
> >     }  while (wrote < 0 && errno = EAGAIN);
> > */
> >
> >
> You can also look at iperf code, ttcp code etc.
> --
> Web1: http://wand.net.nz/~iam4/
> Web2: http://www.jandi.co.nz
> Blog: http://iansblog.jandi.co.nz
>

Did you implemented a similar solution in the code that you sent to
me? I didn't have enough time to check your code because I was busy on
the ccid-4 patches.

Leandro.
