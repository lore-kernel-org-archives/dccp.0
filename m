From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 13 Dec 2005 13:11:47 +0000
Subject: Re: [PATCH 2/3] DCCP: Introduce CCID2
Message-Id: <39e6f6c70512130511j1c45c89ag8d1ebdc0f14b4493@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20051213093224.GB8532@tribal.sorbonet.org>
In-Reply-To: <20051213093224.GB8532@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/13/05, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> Initial support for CCID2 [TCP-like].  CCID2 is missing:
> * ECN nonces.
> * Detecting ECN marked ACKs.
> * Determining when flows go silent [ack of acks business].
>
> Support for changing the receivier and transmitter half-connection CCID is
> available through setsockopt.

Its awesome that you followed the style and managed to fit CCID2 into
the existing pluggable ccid infrastructure, I was fearing we'd need to
redesign it to support CCID2 properly, it may well be that we decide
to do that to converge with TCP to a common congestion control
infrastructure, but thanks a lot for trying it with the current
framework! I'll be looking at it and hope Ian and Dave can provide a
helping hand with much appreciated comments on your work!

- Arnaldo
