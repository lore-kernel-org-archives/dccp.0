From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Jan 2008 16:56:34 +0000
Subject: Re: panic on 2.6.24rc5
Message-Id: <20080107165634.GA19629@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > But what should I exactly test? Just whether the delays are gone or something 
| > more? I'll try to when I have some time (hopefully during weekend).
| 
| If the kernel oopses, if the results are the same or are some problem
| introduced in the patches by Gerrit. I.e. you would help us to narrow
| down the problem by trying a binary search of changeset history built
| kernels. 
| 
| Please take a look at Documentation/BUG-HUNTING in the kernel sources.
| The process is somehow time consuming and its understandable if you
| can't perform it, your reports are already of great help, but if you can
| try helping us to narrow down exactly when some bugs you notice
| appeared, or if they were always present after some kernel builds, we'd
| be really grateful :-)
I have tried to obtain the oops reported by Tomasz, but could not
trigger it. I used iperf on the loopback (127.0.0.1) and got 66.4
Mbits/sec out of it. 
Would also like to ask for more information if at all possible.
