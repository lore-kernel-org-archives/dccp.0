From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 19 Sep 2006 21:04:12 +0000
Subject: Re: [PATCH 6/10]: [DCCP] CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <5640c7e00609191404g7d29d8e8lc6a60e169cae04ba@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060914171207.GG20651@mandriva.com>
In-Reply-To: <20060914171207.GG20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/20/06, David Miller <davem@davemloft.net> wrote:
> From: Arnaldo Carvalho de Melo <acme@mandriva.com>
> Date: Thu, 14 Sep 2006 14:12:07 -0300
>
> > If not enough cwnd is available, tell the sender to check again as soon as
> > possible.  This will increase CPU utilization (polling frequently for cwnd) but
> > will improve network performance.  That is, the sender will need to wait less
> > before detecting the increase of cwnd.  A better architecture would be for the
> > CCID to call-back (or dequeue) from DCCP when it is able to transmit traffic --
> > not the other way around as it currently occurs.

Remember Dave merged my tx queueing recently so this is available now

> Applied, but this is expensive.
>
> Consider having 100,000 DCCP sockets, some large percentage of
> which are polling in this manner, it simply doesn't scale.
>
Agree.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
