From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 28 Dec 2006 01:45:49 +0000
Subject: Re: [PATCH 1/1]: Fix packet tardiness bug in CCID 3
Message-Id: <5640c7e00612271745q2554bb29rd98824548e6ef5b7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612212044.42230@strip-the-willow>
In-Reply-To: <200612212044.42230@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Fix packet tardiness BUG
>
> Problem:
> --------
>  Due to packet scheduling in CCID 3, it can happen that the
>  actual send time of a packet is later than t_now: in this case
>  t_nom < t_now.
>  This case brings the entire packet scheduling out of sync, since
>  the next packet is scheduled at t_nom + t_ipi, and t_nom is in
>  the past.
>
> Fix:
> ----
>  Update t_nom to t_now whenever a packet is late due to scheduling
>  (and then t_nom < t_now). This update takes place in ccid3_hc_tx_
>  send_packet. In between calls to this function, it is irrelevant
>  if t_nom < t_now (since it will be caught eventually).
>
Agree with the problem statement and your fix helps but I think this
fix isn't quite right and mine uses a bit too much CPU resource.

The problem with yours is that it resets t_nom whenever it is late
rather than just due to t_ipi changing. The problem like this is that
if the packet is late for other reasons then we shouldn't slow down
following packets as it hurts performance. Many cases the result will
be negative but low value.

I'll go back and rework my patch a little.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
