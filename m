From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 16 Aug 2010 21:14:06 +0000
Subject: Re: Problems with idle DCCP connections
Message-Id: <1281993246.13085.42.camel@sjerolaptop.homelinux.net>
List-Id: <dccp.vger.kernel.org>
References: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
In-Reply-To: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> | I do, however, see a bunch of messages like the following
> | in /var/log/messages when using CCID-3: "dccp_sane_rtt: RTT sample
> | 8644424 out of bounds!"
> | 
> This message warns that the network has an unusually high RTT (8.64 seconds).
> 
> The warning is issued whenever the RTT exceeds 3 seconds, to avoid that the
> sending rate of CCID-3 is reduced too much (since X is proportional to s/RTT).
> 
>  #define DCCP_SANE_RTT_MAX       (3 * USEC_PER_SEC)

My network RTT is nowhere near 8 seconds; it should be ~1ms... I'm
running my tests between VMs on the same machine... This must be a
result of the TFRC algorithm you mentioned that penalizes connections
with idle periods?

> 
> | I will pull the current tree and double check it; however, my problem
> | (or at least the symptoms) appears to be fixed without CWV. I'll let you
> | know how the new tree works by Monday or Tuesday.

The current tree is also working perfectly. I ran several tests with
CCID-2 that had 5 second idle periods every few seconds and DCCP didn't
clamp down the sending rate. The transfer rate during the connected
periods was ~400Kbps, but that's a result of my research software, not
DCCP.

Samuel Jero

