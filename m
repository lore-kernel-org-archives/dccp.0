From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 14 May 2008 17:39:40 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <1210786780.31221.8.camel@w-sridhar2.beaverton.ibm.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

On Wed, 2008-05-14 at 09:06 -0700, Ulrich Drepper wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Gerrit Renker wrote:
> > ... but it would still be good to have. 
> > [...]
> 
> Thanks, but I think I got this already from previous mails.

SCTP is another protocol that needs to be supported in getaddrinfo().
The minimum support that is good to have is to handle the following
values of ai_socktype and ai_protocol.
  SOCK_STREAM, IPPROTO_SCTP
  SOCK_SEQPACKET, IPPROTO_SCTP

Thanks
Sridhar
> 
> The question is: is either DCCP or UDPlite important enough to be
> returned in the default list when socktype and protocol are zero?
> 
> - --
> ➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.7 (GNU/Linux)
> 
> iD8DBQFIKw342ijCOnn/RHQRAmnrAKCO0sevJbyZXNoFG12jSg1NjPC+5wCfUlyH
> cLqvVRQ1gmTkkwl5JnqA9go> =QRU/
> -----END PGP SIGNATURE-----
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

