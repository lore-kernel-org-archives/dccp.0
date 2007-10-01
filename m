From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 17:33:37 +0000
Subject: Re: [PATCH 1/11]: Auxiliary function for smallest-fit option lengths
Message-Id: <200710011833.37867@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.11436@strip-the-willow>
In-Reply-To: <200710011518.11436@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > +/* Find smallest-fit for @value, but not more than 6 bytes (current m=
aximum) */
|  > +static inline u8 dccp_bytes_per_value(const u64 value)
|  > +{
|  > +=A0=A0=A0=A0=A0if (value > 0xFFFFFFFFull)
|  > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return 6;
|  > +=A0=A0=A0=A0=A0return value > 0xFFFF? 4 : (value > 0xFF? 2 : 1);
| =20
|  Gerrit, one more coding style request: please always add an space after
|  the '?'.
Thank you for spotting - I will take this `home' and do the same for all pa=
tches in the
test tree.
I wish I could save you these requests, but the question of space or not sp=
ace was not=20
very clear to me - I could find=20

Will in any case also re-read Documentation/CodingStyle and update the patc=
hes if anything is not
conform.

Gerrit=09
