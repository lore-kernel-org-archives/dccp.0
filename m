From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 05 Dec 2006 20:39:19 +0000
Subject: Re: CCID 3 performance - some further thoughts
Message-Id: <5640c7e00612051239q7dcc9e8dxc68af0c187442290@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612052019.32837@strip-the-willow>
In-Reply-To: <200612052019.32837@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/6/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I have been experimenting with CCID 3 on various computers,
> below is a list of observations:
>
>  * I didn't use netem or anything (no loss), yet the receiver reported loss

I have seen this too. Remember with CCID3 we are not ack clocking so
if algorithm is wrong and receiver can't keep up then this will
happen. As it is calculating loss intervals etc then it may become
overloaded... see also comments on iperf
>
>  * I quite frequently got those messages from tfrc_calc_x, like
>
>    tfrc_calc_x: Value of p (29) below resolution. Substituting 100
>
>    This should not happen - I believe that these p measurements are bogus
>    and we should check if the loss rate computation is ok.

Is this saying loss is very small? If so then it might be right - I
was getting 40 Mbits/sec and got about 5 of these in 20 seconds. 5
packets out of 200,000 is a very low rate of loss.
>
>  * the behaviour of iperf is very unpredictable, sometimes it seems that
>    throughput is directly related to current system load
>
Iperf is totally predictable with TCP. So is ttcp with TCP. Both are
unpredictable with DCCP. Therefore I think the problem is DCCP. I also
agree that system load makes a difference. Just did some quick tests
on my P4 1.2 GHz machine - my fastest :-( . Iperf on TCP uses 75% of
available CPU and there is idle time. Iperf on DCCP uses 100% of
available CPU and no idle time.... So DCCP sucks the CPU and this
explains some of our issues. Andrea was on the right track when he
said we need to profile it..

>  * the RTT values are almost always higher than the RTT computed by ICMP
>    ping - highly desirable to find ways of obtaining sharper estimates
>
How much higher? I didn't use to see this when using dccpprobe but
haven't tested recently.

>  * would it make sense to define an RTT cut-off value, such as e.g. 2MSL
>    (120 seconds) and regard all RTT estimates above this value as nonsensical?
>    E.g.: #define DCCP_SENSIBLE_RTT_VALUE_MAX 120 * USEC_PER_SEC
>
It would make sense to put debugs to say when this is happening as we
have bugs in if we are getting readings like that. Even have it at 4
seconds - remember what the speed of light is and how far you can get
in that time - there's no need to have it as high as 120 seconds.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
