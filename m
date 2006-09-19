From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 19 Sep 2006 21:43:55 +0000
Subject: Re: [PATCH 6/10]: [DCCP] CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <20060919214355.GA3709@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <20060914171207.GG20651@mandriva.com>
In-Reply-To: <20060914171207.GG20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Sep 20, 2006 at 09:28:51AM +1200, Ian McDonald wrote:
> Understand totally. I wasn't saying tx queueing would solve world
> hunger. It just helps you with the proper approach - doesn't solve it

I'm sure DCCP will one day solve world hunger---TCP failed.

> If tx queueing doesn't help, how do you drain your tx queue when you
> don't have one :-)

I said that on purpose to make you "happy" =D but I didn't add a reference---you
spotted it anyway.

One thing I want to experiment with [now that we have tx queueing] is a "writev"
style API for sending multiple packets with one syscall.  Not quite writev
because that is scatter gather i/o but i call it writev anyway =D.  Perhaps we
can add a flag to sendmsg() which tells it to use the iov as multiple packets
rather than a single packet scattered about.  The idea is that you should be
able to send across bulk data with less context switches.  The combination of
writev, tx queueing and ccid pull should lower CPU utilization, and I'm
wondering by how much [i.e. is it worth the effort?]
