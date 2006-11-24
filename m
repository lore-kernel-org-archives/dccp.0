From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 10:05:34 +0000
Subject: Re: [PATCH 6/6]: Tidy up unused structures
Message-Id: <200611241005.34519@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.46843@strip-the-willow>
In-Reply-To: <200611211545.46843@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > --- a/net/dccp/proto.c
|  > +++ b/net/dccp/proto.c
|  > @@ -469,9 +469,6 @@ static int do_dccp_setsockopt(struct soc
|  > =A0
|  > =A0=A0=A0=A0=A0=A0lock_sock(sk);
|  > =A0=A0=A0=A0=A0=A0switch (optname) {
|  > -=A0=A0=A0=A0=A0case DCCP_SOCKOPT_PACKET_SIZE:
|  > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0dp->dccps_packet_size =3D val;
|  > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0break;
| =20
|  ... printk(KERN_WARNING "setsockopt(PACKET_SIZE) is deprecated, "
|  =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
"fix your app\n");
Many thanks for spotting this - I will update the patch and resubmit it.
How bad to think what happens if 1 gets re-allocated and an old app tries
to set it ... :-x


Gerrit
