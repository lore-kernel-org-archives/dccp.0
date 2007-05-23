From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 23 May 2007 02:56:36 +0000
Subject: Re: problem with CCID3 loss events
Message-Id: <5640c7e00705221956j5e00e6e9ta3d17b48c5a22b7b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <9442.39900.qm@web30009.mail.mud.yahoo.com>
In-Reply-To: <9442.39900.qm@web30009.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there Burak,

I've got a few comments here as I'm certainly not seeing that sort of effect.

I think your main problem is in your queue length and possibly your
netem setup (you don't give your scripts for that).

You've set your queue length for CCID3 at 100 and coupled with netem
behaviour of having very low buffers by default you can end up with a
send rate of virtually zero. I normally use a queue of no more than
32.

In your netem diagram I notice you have two links constrained.
Normally an input constraint doesn't work unless you do some other
magic (see OSDL Wiki). I just do the following.

/sbin/tc qdisc add dev lan0 root handle 1:0 netem delay $1ms
/sbin/tc qdisc add dev lan1 root handle 1:0 netem delay $1ms
/sbin/tc qdisc add dev lan0 parent 1:1 handle 10: tbf rate $2kbit
buffer 10000 limit 30000

Notice also the buffer and limit settings being altered. This makes a
BIG difference as otherwise you get large amounts of consecutive
discard which sends momentary loss up to 100% which knocks
send/receive rate close to zero.

I also hope you didn't apply patch 29 as that is my experimental
patch. It won't actually work without the corresponding parameters to
sendmsg so probably won't affect your results, but if you did reuse
some of my client code there is a possibility you may have done
this...

With your TCP fairness graphs - did you compare against Reno or BIC?
Remember TFRC is based on Reno performance. Those graphs are
interesting and back up my theory about buffer size as the performance
gradually heads up to the right values when CCID3 slowly recovers
which suggets it's getting clobbered way too hard at the beginning.
Remember also if you've got too large buffers you're going to see way
too long to correct - which is happening in your delay graph.

Lastly my code is not fully RFC compliant although I'm certainly
seeing the right rates here in my research or roughly so anyway.
Gerrit Renker has done a whole lot more good work on bringing closer
to compliance. Also there probably will be bugs lying around but
certainly try some of my suggestions and report back.

Regards,

Ian

PS I've updated my website with some of the content from this email.

On 5/21/07, Burak Gorkemli <burakgmail-dccp@yahoo.com> wrote:
> Hi,
>
> I did some CCID3 tests lately with 2.6.20final_dccp (2.6.20 with Ian's patches applied - not the latest patches BTW, the ones in http://wand.net.nz/~iam4/dccp/patches20/). From the tests, I realized that DCCP behaves OK when there is no loss. However, when packets are started to be lost, DCCP nearly shuts itself down and can barely send any packet for a time. I suspect there is something wrong with the loss rate calculation. Any comments on this?
>
> A detailed report is available in http://home.ku.edu.tr/~bgorkemli/dccp/DCCP_Tests.htm
>
> Burak
>
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
