From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 14 May 2008 18:06:16 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <482B2A18.6000708@redhat.com>
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
> Do you intend to 
> implement "dccp" when parsing /etc/services, though?

No special support is needed.  This is just a string.  Add */dccp
entries and see it just work.


Just to conclude this: I will add none of DCCP, UDPlite, SCTP to the
default list.  For now.  Maybe SCTP take off at some point and is worth
it.  But not now.

- --
➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKyoY2ijCOnn/RHQRAsVmAKCPtd+MIVisShBE6exgIh6AJoGWmQCgkaHt
WYuOfl63Q0oS1TdWYmhP95A=2/DS
-----END PGP SIGNATURE-----
