From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 08:43:51 +0000
Subject: Re: [PATCH 1/5] CCID 4: Adds Kconfig, Makefile, and new CCID to include/linux/dccp.h
Message-Id: <200709250943.52016@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070920112021.GB1288@kikai.katei.fi>
In-Reply-To: <20070920112021.GB1288@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Ian McDonald wrote:
|   + =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 16-20ms to match the typical multimedia=
 inter-frame interval
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 100ms as a reasonable compromise [defa=
ult]
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 1000ms corresponds to the lower TCP RT=
O bound (RFC 2988, 2.4)
|  > +
| =20
|  But Linux actually uses 250 ms for TCP here, not 1000 ms. You might
|  want to add that.
| =20
The others are not guilty of this change - the text was copied verbatim fro=
m the CCID3 menu.
And the CCID3 menu was copied from emails on dccp@ietf. I think Colin Perki=
ns suggested the
lower, frame-based value, whereas 100ms were suggested by Mark Handley. Goo=
d to know about
the Linux value -- this is all meant for experimentation, maybe the 1000ms =
can then go?
I have been using the default of 100ms for a long while, but not done feedb=
ack loss tests.
