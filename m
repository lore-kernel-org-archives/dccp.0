From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 27 Jul 2007 15:38:06 +0000
Subject: Re: [PATCH 4/5]: Always support Ack Vectors
Message-Id: <200707271638.06836@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.49095@strip-the-willow>
In-Reply-To: <200707261356.49095@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > [DCCP]: Always support Ack Vectors
|  >
|  > This removes CONFIG_IP_DCCP_ACKVEC for reasons of inter-operability.
|  >
|  > In RFC 4340 requires CCID2 as a kind of default (section 10):
|  > =A0"A DCCP implementation intended for general use, such as an impleme=
ntation
|  > =A0 in a general-purpose operating system kernel, SHOULD implement at =
least CCID 2.2
|  >
|  > RFC 4341, section 4 says that the use of "Ack Vector is MANDATORY on C=
CID 2 half-connections".
|  > (This was so far ensured via Kconfig option). New connections start wi=
th CCID 2 for both
|  > endpoints [RFC 4340, sec. 10]
|  >
|  > Taken together this indicates that Ack Vectors should not be disabled =
in the build process.
|  >
|  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
| =20
|  NAK.
| =20
|  Only CCID2 needs Ack vectors, CCID3 doesn't.
|
This is not so much about which CCID needs but about a minimally-compliant =
implementation in
terms of compile-time options. The point that I wanted to make is the follo=
wing:
   =20
 DCCP mandates a `minimum implementation' =3D CCID2
     =3D> CCID2 mandates Ack Vectors=20
     =3D> Ack Vectors are not optional but mandatory

|  If we're going to tidy this up the code should be conditional on
|  CCID2. As I read this you're making it conditional on DCCP.
Hm maybe that is your point - I have just checked, one can actually still d=
isable CCID2 in Kconfig
- did you mean that? In any case, using DCCP entirely without CCIDs is poin=
tless, it will simply
not work. And this is a bug - a user who disables both CCIDs ends up with a=
 DCCP stack which will
simply not work (there is no `null' CCID).
Using CCID3 only, on the other hand, does not agree with the RFC4340 idea o=
f an implementation which=20
minimally speaks CCID2.=20

I think your point is valid, from my perspective the best thing seems to re=
move CCID2 from the optional
state in Kconfig and make it a fixed default.

The other point you are raising is about _setting_ (as opposed to compiling=
) the CCIDs, and here I=20
agree, more work can be done.

  =20
|  While we're at, we should turn ack vectors off by default for CCID3
|  (if they're built) and on for CCID2.
That is a good point and definitively something to add when we have discuss=
ed what and how this
patch should be realised.

=20
|  If you want me to come up with an alternative patch, please tell me.
Please do - it can only be good to discuss the different ideas, and maybe w=
e can come up with an
even better solution.
