From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Oct 2007 13:08:37 +0000
Subject: Re: [PATCH 5/14]: Clean up remains from old feature-negotiation infrastructure
Message-Id: <200710041408.37460@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.38598@strip-the-willow>
In-Reply-To: <200710031502.38598@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  Your code doesn't quite match your description as removing one line of
|  code from a function. I'm assuming this is OK but raising it just in
|  case.
| =20
Thanks - I have put the hunk below into the earlier patch=20
=09
	"[DCCP]: Cleanup routines for feature negotiation"

The function dccp_feat_clean() is removed by this patch (5/14), and the hun=
k below
can go into the earlier patch without problems (compile-tested the exchange=
).
| =20
|  > --- a/net/dccp/proto.c
|  > +++ b/net/dccp/proto.c
|  > @@ -234,7 +234,6 @@ int dccp_destroy_sock(struct sock *sk)
|  > =A0 =A0 =A0 =A0 dp->dccps_hc_rx_ccid =3D dp->dccps_hc_tx_ccid =3D NULL;
|  >
|  > =A0 =A0 =A0 =A0 /* clean up feature negotiation state */
|  > - =A0 =A0 =A0 dccp_feat_clean(dmsk);
|  > =A0 =A0 =A0 =A0 dccp_feat_list_purge(&dp->dccps_featneg);
|  >
|  > =A0 =A0 =A0 =A0 return 0;
|  > -
| =20
