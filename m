From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 14 May 2008 16:06:16 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <482B0DF8.9060001@redhat.com>
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
> ... but it would still be good to have. 
> [...]

Thanks, but I think I got this already from previous mails.

The question is: is either DCCP or UDPlite important enough to be
returned in the default list when socktype and protocol are zero?

- --
➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKw342ijCOnn/RHQRAmnrAKCO0sevJbyZXNoFG12jSg1NjPC+5wCfUlyH
cLqvVRQ1gmTkkwl5JnqA9go=QRU/
-----END PGP SIGNATURE-----
