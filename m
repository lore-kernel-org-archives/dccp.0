From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 27 Aug 2006 04:02:05 +0000
Subject: Re: low tx speed in ccid3 after loss
Message-Id: <5640c7e00608262102h6eb27277oedcf0cff868043ac@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
In-Reply-To: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/27/06, Burak Gorkemli <burakgmail-dccp@yahoo.com> wrote:
> Hi,
>
> After applying Ian's patches (except for bestpacketnext) I did some tests with ccid3 and came across a problem. In some cases when packet loss occurs, transmit rate drops down and stays there, with almost no increase. Besides, p value is set to a value bigger than zero after the loss, and does not change again, although no loss occurs - which may be the explanation of the unchanging tx rate ???

I haven't seen that behaviour - my p keeps changing.
>
> My test configuration is as follows: I am using two machines, one of which is the ttcp_acme sender and the other ttcp_acme receiver. netem configured to control the rate on both of them such that the link between the machines is 128Kbps with RTT0 ms. Below is the output of the ttcp_acme sender.  I modified the code to print  tfrctx_x and  tfrctv_x_calc also, so colums below are as follows: "tv_sec.tv_usec tfrctx_x tfrctx_x_calc tfrctx_x_recv tfrctx_rtt tfrctx_p".
>
Which machine was netem on or did you put it on both? I usually put it
on a middle box. I haven't rate limited though - I put loss in
instead. I'll test it like that next week. I've stopped using ttcp now
and use iperf as ttcp was giving me some strange results earlier ages
ago - I should relook at it though.

> Packet loss occurs only at the beginning, and after then I see no dropped packets in netem - only requeues.
>
> ttcp-t: buflen%6, nbuf00, align384/+0, portP01  dccp(inet)  -> thinkpad
> 0.000050 256 0 0 0 0
> 0.555739 2463 0 0 103924 0

Will have a better look at later. I do have a theory though - the
CCID3 receiving code only informs about loss when there is a change in
loss. It should stabilise the sending in equilibrium at 128 kbits/sec.
However I am thinking if your buffers for netem aren't big enough and
you get a loss early on then it will get that loss, bring the rate
down and then you won't get any more loss so it won't increase the
rate. I'll have to check whether we are RFC compliant there - seems
nasty that you can't report the loss dropping - at present the code
recalculates loss every time there is one and if you only get one then
you could get in trouble...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
