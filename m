From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Dec 2006 08:34:54 +0000
Subject: Re: [BUG] CCID3 performance
Message-Id: <200612040834.54909@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
In-Reply-To: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  I highly suggest the use of oprofile in case you aren't using it yet. =
=A0To
|  relieve CPU usage:
|  * boot parameter: =A0clock=3Dtsc
|  * the most expensive thing should be checksum calculating [~25%]
This is helpful, many thanks. I was using an older 2xP3 Xeon 700Mhz with 2G=
B Ram and e100
card. I sometimes think it may be the waiting/sleeping/polling which slows =
things down, but
I am speculating ... it may be something.
