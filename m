From: David Miller <davem@davemloft.net>
Date: Tue, 13 May 2008 22:34:30 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080513.153430.47909155.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 13 May 2008 13:23:25 -0300

> What would be the problem of SOCK_DCCP being handled in glibc in such a
> fashion?

I don't understand why this isn't exactly what is being done.

We have to update glibc to handle SOCK_DCCP correctly, just
get over it :-)
