From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Wed, 26 Jul 2006 07:01:15 +0000
Subject: Re: Help: how to get the latest code?
Message-Id: <20060726070115.GB6185@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
In-Reply-To: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Jul 26, 2006 at 04:10:58PM +1200, Ian McDonald wrote:
> On 7/26/06, Ma Lin <gavin.malin@gmail.com> wrote:
> >My planned change in CCID2 is something to do with the sequence
> >number, the non-cumulative ACK, and the moving of congestion window.
> >Which files am I suppose to look at?

Changing the dynamics of cwnd should be relatively easy.  I purpousely pulled
out a helper method "change_cwnd" in ccid2 which enables easy logging &
modification of the window.  Also, I think I added "congestion_event()" or
similar, which is called once when there are losses in an RTT.

Screwing with the ACK code is a nightmare.  That's where I found most of the
bugs.  Note that the ack vector is "parsed" twice [which is a design bug: 1)
ackvec.c in option parsing, and 2) in ccid2.c upon reception of an ack].
