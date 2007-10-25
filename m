From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 25 Oct 2007 10:17:14 +0000
Subject: Re: Gstreamer e DCCP: issues related to ccid-3
Message-Id: <200710251117.14404@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
In-Reply-To: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  =A0I'm implementing the dccp plugin for gstreamer and everything goes
|  very well, I can transmit an mp3 sound using ccid-2, but when I try to
|  use ccid-3, I can just send very little via send function and after
|  the function returns 11 (EAGAIN). Is there any different parameter
|  that I should set? I think that the problem that you had in VLC should
|  be the same
This problem (or "feature") is well-known, Ian has also repeatedly pointed =
out
to this. Basically, what your code needs to be able to do is cope with EAGA=
IN,
i.e. when the TX buffer is full and CCID3 decides to throttle the sending s=
peed,
the write call needs to be repeated.

I haven't checked the VLC code lately (it will have such a test), but I kno=
w that=20
Andre Noll developed a very clever way of handling this, by using a "generi=
c chunk queue"=20
for audio chunks which could currently not be sent. He implemented this in =
paraslash
(file dccp_send.c), the sources are on http://www.systemlinux.org/~maan/par=
aslash/

For this most recent feature, it is best to use his git tarball:

  http://www.systemlinux.org/~maan/paraslash/versions/paraslash-git.tar.bz2


I also=20
