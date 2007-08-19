From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 22:06:50 +0000
Subject: Re: Backporting gerrit tree (from git) to 2.6.18. IT WAS:
Message-Id: <20070819220650.GA24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570708180844g3618c9a0v1f6cb69222c9c7f8@mail.gmail.com>
In-Reply-To: <5bc4c4570708180844g3618c9a0v1f6cb69222c9c7f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Sun, Aug 19, 2007 at 09:38:13AM -0300, =E3=83=84 Leandro Sales escreveu:
> Are these operations equivalent? Please, tell me where can I find docs ab=
out skb
>=20
> -   skb->h.raw =3D skb->data;
>=20
> +   skb_reset_transport_header(skb);

That is easy as I left all the old code in include/linux/skbuff.h. Just
look at what the operation does if NET_SKBUFF_DATA_USES_OFFSET is not
defined, that, for the above api is:

static inline void skb_reset_transport_header(struct sk_buff *skb)
{
        skb->transport_header =3D skb->data;
}

skb->h.raw is the old name of skb->transport_header
skb->nh.raw is the old name of skb->network_header
skb->nac.raw is the old name of skb->mac_header
=20
- Arnaldo
