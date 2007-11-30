From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 30 Nov 2007 13:00:47 +0000
Subject: Re: [RFC]: tfrc_tx_hist_rtt
Message-Id: <20071130130047.GB30112@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071129172954.GL12069@ghostprotocols.net>
In-Reply-To: <20071129172954.GL12069@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > I wonder if one could go one step further and also take the timestamp
| > directly when looking up the previous history sample, e.g.
| > 
<snip>
| 
| I thought about that, but ccid3_hc_tx_packet_recv needs a timestamp some
| lines below, when we reuse the ktime_get_real call.
| 
Oh, of course - that was real stupid of me. I think it is even in two occasions where a 
timestamp is needed, below in the same function.

I am really hoping that some time there is a robust RFC1323-like algorithm,
this could solve all the RTT sampling for both CCID2 and CCID3 (also CCID4),
and then there would be a RTT available in the main module (e.g. for better
estimating the Close/CloseReq retransmission timeout).


