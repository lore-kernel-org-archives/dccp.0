From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Nov 2006 00:54:51 +0000
Subject: Re: [BUG] CCID3 no longer works!
Message-Id: <5640c7e00611291654p2d6cdfcaj22907c48cd4e459c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611291504v60e06067h469e8c91293031c9@mail.gmail.com>
In-Reply-To: <5640c7e00611291504v60e06067h469e8c91293031c9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/30/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> There are some clues at least on jandi3 log:
> Nov 30 11:57:49 localhost kernel: [  645.677995]
> ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
> sent
> Nov 30 11:57:49 localhost kernel: [  645.678678]
> ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
> sent
>
> Will start by look at that patch and if necessary then start bisecting.

OK. It's nothing to do with that patch I believe after looking at the
logic. Do need to look at why we get that message though as it
indicates a bug somewhere but that is another bug which has just been
uncovered and there all along!

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
