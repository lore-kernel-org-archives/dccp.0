From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 14 May 2008 14:45:18 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080514144518.GA30578@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ulrich Drepper:
| -----BEGIN PGP SIGNED MESSAGE-----
| Hash: SHA1
| 
| Gerrit Renker wrote:
| > RFC 3493 says that 0 for socktype/protocol means that caller will accept
| > any socket type / protocol, so presumably this does include DCCP and UDP-Lite.
| 
| I know what the RFC says.  But there are a gazillion of protocols out
| there and I won't create a record for all of them in case socktype and
| protocol are zero.  That's just overkill in 99.9% of all cases.
| 
| I assumption is that UDPlite is just too specialized to be useful to a
| wide array of people.  Yes, it case be supported if explicitly requested
| but should be returned if 0/0 is passed in.
| 
Sorry I misunderstood your email. Yes the above case is clear: if
someone supplies 0/0, s/he will probably not want any specialised
protocols in the return list.

This didn't appear in Remi's list. I have completed the list and put the
cases in the table below; `defaults' is interpreted in the way above.

 +--------------+---------------+---------------+---------------+
 | ai_socktype	| ai_protocol	| Return type	| Return Proto  |
 +--------------+---------------+---------------+---------------+
 | SOCK_DCCP	| IPPROTO_DCCP	| SOCK_DCCP	| IPPROTO_DCCP 	|
 | SOCK_DCCP	| 0		| SOCK_DCCP	| IPPROTO_DCCP 	|
 | 0		| IPPROTO_DCCP	| SOCK_DCCP	| IPPROTO_DCCP	|
 | 0		| 0		| (defaults)	| (defaults)	|
 +--------------+---------------+---------------+---------------+


If at all possible, for UDP-Lite it is similar. Since UDP-Lite is
actually just a form of UDP, this seems much less urgent than DCCP -
one might argue that UDP-Lite falls under SOCK_DGRAM/UDP.

 +-------------+-----------------+-------------+-----------------+
 | ai_socktype | ai_protocol	 | Return type |  Return Proto   |
 +-------------+-----------------+-------------+-----------------+
 | SOCK_DGRAM  | IPPROTO_UDPLITE | SOCK_DGRAM  | IPPROTO_UDPLITE |
 | SOCK_DGRAM  | 0		 | SOCK_DGRAM  | IPPROTO_UDP	 |
 | 0	       | IPPROTO_UDPLITE | SOCK_DGRAM  | IPPROTO_UDPLITE |   
 | 0	       | 0		 | (defaults)  | (defaults)      |
 +-------------+-----------------+-------------+-----------------+

... but it would still be good to have. 
