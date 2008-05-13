From: Ulrich Drepper <drepper@redhat.com>
Date: Tue, 13 May 2008 19:14:07 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <4829E87F.1070006@redhat.com>
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
> In any case, getaddrinfo() should be patched to
> [...]

What should be the behavior is socktype and protocol are zero?  Should
these two types be returned by default?  What others?  So far we return
TCP, UDP, and raw socket information.  I'd rather keep the list short
but since we already have raw sockets in there (because they are in
POSIX) I won't reject anything that's more useful than raw sockets.

- --
➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKeh/2ijCOnn/RHQRAhTeAJ9jrv+RS6rkrGJvan9ADq4S86d2XQCggST4
/MYPzB+2s2/m1VYsmUPAeLg=FSYf
-----END PGP SIGNATURE-----
