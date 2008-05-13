From: David Miller <davem@davemloft.net>
Date: Tue, 13 May 2008 07:39:24 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080513.003924.170616140.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 May 2008 08:28:53 +0100

> Is there support for this change or are there reasons to keep SOCK_DCCP?

You'll have to accept it forever since there have been several
kernel releases already with DCCP support added and there are
applications out there.
