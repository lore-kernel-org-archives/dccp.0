From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Dec 2006 20:51:47 +0000
Subject: Re: [PATCH] DCCP: handle EAGAIN case
Message-Id: <200612042051.47838@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612031538.27300@strip-the-willow>
In-Reply-To: <200612031538.27300@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > =A0a) You helped to uncover at least one real bug here:
|  >
|  > =A0 =A0 long delay;
|  >
|  > =A0 =A0 delay =3D msecs_to_jiffies(rc);
|  > =A0 =A0 if (delay > *timeo || delay < 0)
|  >
| =20
|  I was thinking of changing the type from long to unsigned long to
|  match and removing the test too. I agree totally.
For this case I have prepared a patch. With regard to the EAGAIN case I was
half waiting for Arnaldo to say something, for the moment I have put it her=
e:
http://www.erg.abdn.ac.uk/users/gerrit/dccp/experimental_patches/15a_handle=
_EAGAIN.diff

I think we should fix the EAGAIN case. Maybe also something for EINTR (err=
=3D-4).
