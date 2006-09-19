From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 19 Sep 2006 23:06:08 +0000
Subject: Re: [PATCH 6/10]: [DCCP] CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <5640c7e00609191606v423a73bckae1a88a40d8e6c36@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060914171207.GG20651@mandriva.com>
In-Reply-To: <20060914171207.GG20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/20/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> One thing I want to experiment with [now that we have tx queueing] is a "writev"
> style API for sending multiple packets with one syscall.  Not quite writev
> because that is scatter gather i/o but i call it writev anyway =D.  Perhaps we
> can add a flag to sendmsg() which tells it to use the iov as multiple packets
> rather than a single packet scattered about.  The idea is that you should be
> able to send across bulk data with less context switches.  The combination of
> writev, tx queueing and ccid pull should lower CPU utilization, and I'm
> wondering by how much [i.e. is it worth the effort?]

I agree that APIs can improve and after I've done my current research
I'm going to look at that some more.

The sendmsg code can certainly be modified - I've done this for my
bestpacketnext code. If you want have a look at it on my website - it
is real ugly but it works.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
