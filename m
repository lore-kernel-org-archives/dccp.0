From: Tommi Saviranta <wnd@iki.fi>
Date: Fri, 09 Nov 2007 13:39:59 +0000
Subject: Re: How much is available for reading on the socket?
Message-Id: <20071109133959.GA32099@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
In-Reply-To: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Sun, Oct 21, 2007 at 23:00:38 -0300, =C5=81eandro Sales wrote:
> using "ioctl (socket, FIONREAD, &readsize)" I can get how much is
> available to read from the socket using TCP. Is there a equivalent
> option for DCCP?

Looks like dccp_ioctl() happily returns -ENOIOCTLCMD (for now). If you
have IO and memory to waste, you can always recv(..., MSG_PEEK) to work
around this.

