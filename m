From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 14 May 2008 17:57:24 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <482B2804.7040604@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Sridhar Samudrala wrote:
>>   SOCK_STREAM, IPPROTO_SCTP
>>   SOCK_SEQPACKET, IPPROTO_SCTP

This is also in.  Give it a try once the first glibc for F10 rawhide is
built.  Should happen before Monday next week.

- --
➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKygE2ijCOnn/RHQRAmm8AKCroe3jOmDpovf7M7oUhfInIZv6FQCgvuLB
M3XI59EFGTdYxCwNGvDRTSA=x83D
-----END PGP SIGNATURE-----
