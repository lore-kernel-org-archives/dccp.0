From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 21 Aug 2007 14:58:27 +0000
Subject: Re: [PATCH 13/15] [DCCP] options: convert
Message-Id: <20070821145827.GE10392@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Aug 21, 2007 at 02:25:27PM +0100, Gerrit Renker escreveu:
> Sorry this one has a bug also - it compresses a signed 64 bit quantity into a 32-bit unsigned
> value. When re-interpreted as microsecond value (in dccp_sample_rtt), this gives values which
> are way too small.
> 
> Maybe we should keep the dccp_epoch thing, but now with ktime_t, so as to avoid large microsecond values?

Argh, it seems so :-(
 
> In any case, the RTT sampling is not usable - it constantly produces overflow, since the timestamp
> option value is too small.

Reading code and RFC now...
 
- Arnaldo
