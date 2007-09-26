From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 13:28:59 +0000
Subject: Re: Header size of the data packet
Message-Id: <20070926132859.GA8088@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709260619w27b29866l59bbff6747105a97@mail.gmail.com>
In-Reply-To: <5bc4c4570709260619w27b29866l59bbff6747105a97@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Wed, Sep 26, 2007 at 10:19:48AM -0300, =E3=83=84 Leandro Sales escreveu:
> Hi,
>=20
>    according to ccid-4 internet draft, "the estimated header size on
> data packets is 36 bytes (20 bytes for the IP header and 16 bytes for
> the DCCP-data header with 48-bit sequence numbers). The header size
> would be 32 bytes instead of 36 bytes when 24-bit sequence number were
> used in the DCCP-data header."
>    In this case, how can I get this information if dccp will use
> 48-bit or 24-bit sequence number?

So far we're using only 48-bit sequence numbers. To keep your
implementation simple, I suggest you do the same, i.e. don't worry about
24-bit sequence numbers for the time being.

- Arnaldo
