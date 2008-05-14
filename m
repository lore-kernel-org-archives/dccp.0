From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 14 May 2008 17:22:04 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080514172204.GA1036@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| The question is: is either DCCP or UDPlite important enough to be
| returned in the default list when socktype and protocol are zero?
They are probably both not important enough to be returned in the
default list.

But either is important be considered when a user unambiguously specifies
ai_socktype and/or ai_protocol; to avoid bad/brittle workarounds.
