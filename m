From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 05 Dec 2006 21:38:15 +0000
Subject: Re: CCID 3 performance - some further thoughts
Message-Id: <5640c7e00612051338x5c9f02f8q3c21276d596824c1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612052019.32837@strip-the-willow>
In-Reply-To: <200612052019.32837@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/6/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  > * I quite frequently got those messages from tfrc_calc_x, like
> |  >
> |  > tfrc_calc_x: Value of p (29) below resolution. Substituting 100
> |  >
> |  > This should not happen - I believe that these p measurements are bogus
> |  > and we should check if the loss rate computation is ok.
> |
> |  Is this saying loss is very small? If so then it might be right - I
> |  was getting 40 Mbits/sec and got about 5 of these in 20 seconds. 5
> |  packets out of 200,000 is a very low rate of loss.
> This was with a transmit rate of 94.9 Mbits/sec, payload length 1424, and about
> 500 warnings complaining of a p of 29 in
>     20 sec * 94.9 Mbits/sec * 1/(1424 * 8 bits)  = 166608 messages
> So it is 500/166608 ... approximately 0.3% ...
> A loss of p = 29 * 1E-6 would mean that about 5 messages were lost ... indeed not much :-)
>
> I was thinking: maybe have tfrc_calc_x substitute a p=0 instead.
>

Agree... But I'm guessing it will show up other errors and drop more
packets as receiver can't cope now.
>
> |  > * the behaviour of iperf is very unpredictable, sometimes it seems that
> |  > throughput is directly related to current system load
> |  >
> |  Iperf is totally predictable with TCP. So is ttcp with TCP. Both are
> |  unpredictable with DCCP. Therefore I think the problem is DCCP. I also
> |  agree that system load makes a difference. Just did some quick tests
> |  on my P4 1.2 GHz machine - my fastest :-( . Iperf on TCP uses 75% of
> |  available CPU and there is idle time. Iperf on DCCP uses 100% of
> |  available CPU and no idle time.... So DCCP sucks the CPU and this
> |  explains some of our issues. Andrea was on the right track when he
> |  said we need to profile it..
> I can confirm the above - I have been testing on a relatively wide range of hardware,
> and I get the best performance only out of the most recent types of computers (Xeon,
> Dual-Core). Even uniprocessor P4 2.4Ghz struggles to go above 50Mbits/sec.
>
> You are right, profiling seems inevitable ... something to rtfm about.
>
I'm just rebuilding kernel with oprofile support now. Thanks for
pointing that one out Andrea - had read about that previously...
>
> |
> |  > * the RTT values are almost always higher than the RTT computed by ICMP
> |  > ping - highly desirable to find ways of obtaining sharper estimates
> |  >
> |  How much higher? I didn't use to see this when using dccpprobe but
> |  haven't tested recently.
> Ping gives about 0.1 msec, the logs say up to 10000 microseconds, which are a factor
> of 100. You also said something about inflated RTT values earlier.
>

Yes I saw that fairly recently and said that in a message - maybe one
of your logs? There's no way that should be doing that and hadn't seen
that before. i think that's a new bug.
>
> |  > * would it make sense to define an RTT cut-off value, such as e.g. 2MSL
> |  > (120 seconds) and regard all RTT estimates above this value as nonsensical?
> |  > E.g.: #define DCCP_SENSIBLE_RTT_VALUE_MAX 120 * USEC_PER_SEC
> |  >
> |  It would make sense to put debugs to say when this is happening as we
> |  have bugs in if we are getting readings like that. Even have it at 4
> |  seconds - remember what the speed of light is and how far you can get
> |  in that time - there's no need to have it as high as 120 seconds.
> Yes, but -- switching delay? What is a reasonable assumption -- 60 seconds?
>
No switches/routeres hold it for anywhere near that long as you'd need
a huge buffer. rtt to opposite side of the world is 300 msec roughly.
Even via satellite is around 1 second?? 4 seconds is fine to put a
warning in at.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
