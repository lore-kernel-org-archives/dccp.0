From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 13 May 2008 15:50:59 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <OFDBD6E282.6F00998A-ON88257448.0056D40D-88257448.0057105E@us.ibm.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Are they mutually exclusive?

Why not add SOCK_DGRAM/IPPROTO_DCCP support while leaving
the existing stuff alone, and then requiring programs that want to use
getaddrinfo to use it that way?

                                                +-DLS

