From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 14 May 2008 18:07:11 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <482B2A4F.7030908@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Rémi Denis-Courmont wrote:
> Yeah but I don't think ai_socktype = SOCK_STREAM and ai_protocol = 0 should 
> return IPPROTO_SCTP. Me fears this will break to many TCP applications in the 
> field.

That's not happening.  For SOCK_STREAM TCP is returned.

On the other hand, in the moment, for SOCK_SEQPACKET I return SCTP.  If
this is not the preferred solution let me know now.

- --
➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKypP2ijCOnn/RHQRAvxYAJ9EqfwRsQq+SuRmkbtdmVs8aDiyGACeMoqx
KqOzlMnpDpzMz+ccEB6oxBA=DHB9
-----END PGP SIGNATURE-----
