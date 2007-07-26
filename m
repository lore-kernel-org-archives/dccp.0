From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 26 Jul 2007 08:32:03 +0000
Subject: Re: TFRC Faster Restart implementation for Linux DCCP
Message-Id: <200707260932.03166@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
In-Reply-To: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > | =A0Given how TCP handle extensions I think the
|  > | =A0best way for this is a sysctl as can turn it on or off system wid=
e.
|  > | =A0The default, initially, should be off. The other alternative is to
|  > | =A0enable it via a socket option as TCP Nagle does.
|  > Could use a module parameter to the CCID3 module to enable it.
| =20
|  I've decided to go with a socket option for now but this trivial to
|  alter the code around it.
I think this is even better than a module option, since faster restart will
also affect CCID4. The problem with module options is that unloading does n=
ot
really work.

A while ago I noticed that DCCP does not support the SO_KEEPALIVE option, a=
nd the=20
ping probes of FR somewhat link up with this. Maybe something similar to TC=
P_KEEPCNT,=20
TCP_KEEPIDLE, TCP_KEEPINTVL is possible here?

There is an issue with the ping probes, will write up in a separate email.
