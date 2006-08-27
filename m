From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 27 Aug 2006 03:46:58 +0000
Subject: Re: [PATCH 0/7] [DCCP]: Fixes and enhancements
Message-Id: <5640c7e00608262046x598d873cr7a4bcd2df971dac0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200608241516.34448.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200608241516.34448.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/27/06, David Miller <davem@davemloft.net> wrote:
> >
> > I would love 3, 4, 5 to go into 2.6.18 as these resolve long standing CCID3
> > issues that have been in the DCCP tree since inception and have caught a
> > number of people.
>
> Ok, I'll toss 1-5 into 2.6.18

Thanks for that. Are 6 and 7 going into 2.6.19 or do you want Arnaldo
to have a bit more of a look? 6 in particular is trivial.
>
> One thing I don't understand is this description from patch 5:
>
> --------------------
> This gives a theoretical speed of 71.9 Kbits/s. I measured across three
> runs with this patch set and got 70.1 Kbits/s. Without this patchset the
> average was 232 Kbits/s which means Linux can't be used for CCID3 research
> properly.
> --------------------
>
> Decreasing the transfer rate is desirable?  I read this as saying
> this "fix" drops the transfer rate down from 232Kb/sec to
> 70.1Kb/sec.  What's going on here?

DCCP CCID3 (RFC 4342) uses TFRC (RFC 3448) to calculate the desired
rate to send at based on feedback from the receiver. The reason for
this is that TFRC is not ACK/Window based to control rate and TFRC
calculates a rate so that the flow is "fair" when competing with TCP.
TFRC is designed to be smoother than TCP at dealing with loss - more
sine wave than saw tooth.

The calculation is based on the work Padhye et al did in this paper -
http://citeseer.ist.psu.edu/padhye98modeling.html

As it turns out this is based on TCP Reno at that time and modern TCP
variants are more efficient when dealing with loss as can be verified
through iperf but we should implement what the RFC says.

Basically the implementation in the DCCP code was buggy and was
transmitting too fast so I have made it conform to the RFC much
closer.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
