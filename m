From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 15:27:07 +0000
Subject: Re: [PATCH v2 4/9]: Resolve dependencies of features on choice of CCID
Message-Id: <200710021627.07615@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710021306.55993@strip-the-willow>
In-Reply-To: <200710021306.55993@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0{=A0=A0=A0=A0=A0=A0=A0/* !is_l=
ocal: dependencies of the remote (RX) CCID */
|  > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0{ DCCP=
F_SEND_ACK_VECTOR, true, =A0true, 1 },
|  > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0{ 0, 0=
, 0, 0 }
| =20
|  designated initializers, please, that way we can avoid the zeroes and
|  see the name of the fields, which helps understanding without having to
|  go back to the struct definition.
I can add the field-wise initialisers, but have no way of getting rid of th=
e zeroes
at the moment. The problem is that=20
 * the dependencies of the feature-location can be different from=20
 * the dependencies of the feature-remote
as is indeed the case with ccid3_dependencies[2][5]: it which has three dep=
endencies for the
feature-remote, but four for the feature-local.

So the tables can be variable in length, even in their two main rows. The n=
umber of
rows (2), on the other hand, is given by the requirement that features divi=
de into
local/remote, so there is no problem using a fixed-length.=20
If you can think of a more elegant solution of tackling this, I'd welcome s=
uggestions.

Will axe the `const typedef' stuff, thanks.
