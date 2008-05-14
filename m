From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 14 May 2008 14:06:19 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <482AF1DB.1060608@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Gerrit Renker wrote:
> RFC 3493 says that 0 for socktype/protocol means that caller will accept
> any socket type / protocol, so presumably this does include DCCP and UDP-Lite.

I know what the RFC says.  But there are a gazillion of protocols out
there and I won't create a record for all of them in case socktype and
protocol are zero.  That's just overkill in 99.9% of all cases.

I assumption is that UDPlite is just too specialized to be useful to a
wide array of people.  Yes, it case be supported if explicitly requested
but should be returned if 0/0 is passed in.

What I'm asking is whether this is a fair assumption and what the story
of DCCP is.

- --
➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKvHb2ijCOnn/RHQRAlz5AKCvOSOm7PR7ljfyZ9krq0TtzZUTbgCdFLLj
F1fvWvR+VvXUSE5x+VtgsqQ=3Lft
-----END PGP SIGNATURE-----
