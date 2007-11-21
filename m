From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Nov 2007 13:18:12 +0000
Subject: Re: Test tree patch inventory - update
Message-Id: <20071121131812.GA17659@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071120201041.GA24995@ghostprotocols.net>
In-Reply-To: <20071120201041.GA24995@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | > 	[TFRC]: New RX history implementation
| > | 
| > | 
| > | +static struct kmem_cache *tfrcxh;
| > | 
| > | Why "xh"?
| > | 
| > This is a typo, my mistake. I had meant to use the suffix `rxh' to indicate that
| > this static cache is for the RX history, but it somehow merged with `r'
| > from tfrc. Are you okay with tfrc_rxh? I will uploaded a revised patch
| 
| tfrc_rx_hist would be better, its not overly long and for the casual
| reader provides more info.
| 
I just tried this, the problem is that it clashes with 

	struct tfrc_rx_hist {
        	struct tfrc_rx_hist_entry       *ring[NDUPACK + 1];
		/* ... */
	};

Thus changed it to

   	static struct kmem_cache *tfrc_rxh_cache;

   and uploaded a revised patch. If you are not ok with the naming
   scheme, let me know and I'll revise it.

I am working on the leaked skbs issue, either there will be a revised
patch later or I'll fix this after work.
