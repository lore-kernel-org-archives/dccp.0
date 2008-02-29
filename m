From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 29 Feb 2008 14:23:34 +0000
Subject: Re: [DCCP] [RFC]: Getting rid of unwieldy struct prefixes
Message-Id: <20080229142334.GL4306@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Feb 29, 2008 at 09:45:18AM +0000, Gerrit Renker escreveu:
> [CCID-2]: Get rid of ccid2hc{tx,rx}_ prefixes
> 
> Following discussion with Leandro yesterday, this is a  request-for-comments
> patch to fix two problems caused by the ubiquitous long "hctx->ccid2htx_" and
> "hcrx->ccid2hcrx_" prefixes:
>  -> code becomes hard to read;
>  -> multiple-line statements are almost inevitable even for simple expressions;
>  -> the prefixes are not really necessary - compare with "struct tcp_sock".

I haven't checked, is this over what is now on the test tree or on
upstream?

- Arnaldo
