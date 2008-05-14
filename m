From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 14 May 2008 17:43:41 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <482B24CD.2040209@redhat.com>
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
> But either is important be considered when a user unambiguously specifies
> ai_socktype and/or ai_protocol; to avoid bad/brittle workarounds.

OK, I added the support.  Will be in glibc 2.9.

But what about $subject?  What is the story with SOCK_DCCP?  I added it
now but if it's going away I'd rather remove it.

- --
➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKyTN2ijCOnn/RHQRAhyWAJoDEgLDYcL/VUQyz5ykje2r4FWVFwCbBdvq
U1W/yHRv5cAuuWr4927IGUw=rjjM
-----END PGP SIGNATURE-----
