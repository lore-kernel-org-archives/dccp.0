From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 16 Jul 2011 17:47:14 +0000
Subject: Re: [PATCH 02/07] dccp: support for exchanging of NN options in established
Message-Id: <4E21CEA2.8030509@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enigF977201071956EE24C8F152A"
List-Id: <dccp.vger.kernel.org>
References: <1310650955-5159-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1310650955-5159-3-git-send-email-gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org

--------------enigF977201071956EE24C8F152A
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

You have my Signed-off-by for this patch. I would recommend making a
minor change in one of the comments. See below.

On 07/14/2011 09:42 AM, Gerrit Renker wrote:
> This patch provides support for the reception of NN options in (PART)OP=
EN state.
> It is a combination of change_recv() and confirm_recv(), specifically g=
eared
> towards receiving the `fast-path' NN options.
>=20
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Signed-off-by: Samuel Jero <sj323707@ohio.edu>

>   * dccp_feat_parse_options  -  Process Feature-Negotiation Options
>   * @sk: for general use and used by the client during connection setup=

>   * @dreq: used by the server during connection setup
> @@ -1286,6 +1394,15 @@ int dccp_feat_parse_options(struct sock *sk, str=
uct dccp_request_sock *dreq,
>  			return dccp_feat_confirm_recv(fn, mandatory, opt, feat,
>  						      val, len, server);
>  		}
> +		break;
> +	/*
> +	 *	Support for exchanging NN options on an established connection
> +	 *	This is currently restricted to Ack Ratio (RFC 4341, 6.1.2)
> +	 */

This comment is out of date. We now process Sequence Window updates
dynamically. I would remove the second line.

> +	case DCCP_OPEN:
> +	case DCCP_PARTOPEN:
> +		return dccp_feat_handle_nn_established(sk, mandatory, opt, feat,
> +						       val, len);
>  	}
>  	return 0;	/* ignore FN options in all other states */
>  }



Samuel Jero
Internetworking Research Group
Ohio University


--------------enigF977201071956EE24C8F152A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4hzqYACgkQEwoGUlJjrt+sFACgrzI5Cj171ejrvKEczaGStNaI
0VoAn1RvZ2LYXAx1WX1C4Z2Zjs0IdsZs
=qY3D
-----END PGP SIGNATURE-----

--------------enigF977201071956EE24C8F152A--
