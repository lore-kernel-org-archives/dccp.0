From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Aug 2007 08:46:31 +0000
Subject: Re: [PATCH 3/6] DCCP: Introduce CCID3 extensions
Message-Id: <200708300946.32029@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708291134.45030.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291134.45030.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A style comment - I like the idea of the extensions and can see your point.
To be true, if the code were analysed for extensions then the rfc344bis-00 
extensions would probably also count, as well as the erratum for the SYN
RTT sample.

When using a one-bit flag (which automatically behaves like a Boolean type), 
such as
	/* @ccid3hctx_faster_restart_on: whether Faster Restart is enabled */
	/* ... */
	u8				ccid3hctx_faster_restart_on:1;

the testing and setting code would be smaller - if a little less elegant.
