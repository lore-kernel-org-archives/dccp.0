From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 26 Sep 2007 09:04:22 +0000
Subject: Re: [PATCH 8/8]: Support inserting options during the 3-way handshake
Message-Id: <200709261004.22954@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.51394@strip-the-willow>
In-Reply-To: <200709251530.51394@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > --- a/net/dccp/options.c
|  > +++ b/net/dccp/options.c
|  > @@ -160,7 +160,7 @@ int dccp_parse_options(struct sock *sk,=20
|  > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (=
len !=3D 4)
|  > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0goto out_invalid_option;
|  > =A0
|  > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0tse =
=3D dreq? &dreq->dreq_tstamp : dp->dccps_tstamp;
|  > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0tse =
=3D dreq? &dreq->dreq_tstamp : &dp->dccps_tstamp;
| =20
|  And here you fix it in an unrelated patch, tsc, tsc :-)
These kind of errors don't happen on purpose, if I submitted everything as =
one big patch=20
no one would notice. But with one problem split into several tens of patche=
s it easily=20
happens that one hunk is fixed while quilt is in a different patch - and th=
en it gets assigned=20
the wrong patch. I missed this hunk so thank you two for spotting this - it=
 is fixed now.
