From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 22 Aug 2007 12:29:12 +0000
Subject: Re: [PATCH 2/3]: Provide 10s of microsecond timesource
Message-Id: <20070822122912.GO10392@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200708212000.16659@strip-the-willow>
In-Reply-To: <200708212000.16659@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Aug 22, 2007 at 09:31:13AM +0100, Gerrit Renker escreveu:
> Quoting Arnaldo Carvalho de Melo:
> |  > [DCCP]: Provide 10s of microsecond timesource
> |  > 
> |  > This provides a timesource, conveniently used for DCCP timestamps, which 
> |  > returns the elapsed time in 10s of microseconds since initialisation. 
> |  > This makes for a wrap-around time of about 11.9 hours, which should be
> |  > sufficient for most applications.
> |  
> |  Why do it at kernel boot (or at dccp module load time to be more
> |  precise)? Why not do it at sock creation time? Then it will be 11.9
> |  hours after the socket is created.
> |  
> |  This is how dccps_epoch was used BTW :-)
> This was done intentionally to keep it small. I figured that if there are e.g.
> 60 sockets, then each of them needs a ktime_t variable, plus an initialisation
> (and another one for child sockets); and then it may be that the dccp_timestamp()
> is never called: currently the only customer of dccp_timestamp() is CCID3 (for
> the SYN RTT sample). If CCID2 is used, then all this is provided but not used.
> Hence, for the occasional timestamp keeping it separate comes at a lower cost.
> 
> Actually, the problem is not like the sequence number arithmetic, since normal
> subtraction (not modulo-2^32 subtraction) is used, i.e. if the socket is created
> 5 seconds before the 32-bit value wraps around, then 5 seconds later the time
> difference to an earlier timestamp would reach a huge value (2^32 - 1 - 5 seconds).
> 
> To avoid this problem, one would have to use modulo-2^32 subtraction, ie. cast to
> s64 and see if the difference is negative, and add 2^32 if it is.
> 
> But this all seems to me over-engineering: the problem occurs only every 11.9 hours,
> and if it occurs earlier, it is caught by dccp_sample_rtt() which will reduce the 
> huge value to 3 seconds (max RTT).
> 
> And it is once again CCID3 which causes these headaches with its dependence on precision.
> 
> I can see the following alternatives, what is your stance regarding:
>  (a) keep as it is (probably not agreeing due to this email?)
>  (b) keep principle, but use at socket creation (glitch comes possibly later, but will still occur)
>  (c) ditch principle and use even lower granularity - milliseconds (jiffies seems like a natural match)
> 
> My personal favourite is (c).

I think that we should provide the best granularity available we can
while not impacting non DCCP code (remember the net_enable_timestamp()
case?). CCID3 probably is what people will try first, I guess.

Well, I'll merge your patches as is, it fixes the bug I introduced and
as you say dccp_sample_rtt will bound it to max RTT.

On the overengineering front I just thought that if this is needed just
by some CCIDs then the initialization costs could be shifted to
ccid_hc_tx_init and the option insertion to ccid_hc_tx_insert_option...
Just checked and dccp_insert_option_timestamp already is called only
from two places: ccid3 and from dccp_insert_options when sending the
REQUEST packet, also on behalf of ccid3, I'll check if we can somehow
shift this option insertion in the REQUEST packet entirely to the
CCID3 code.

Humm, there is also elapsed time in dccp_timestamp_echo, but that is a
delta, so we should have enough space on 32 bits... but because of that
we need to do timestamping on dccp_parse_options and not in the CCID
code that needs this... i.e. if we want to avoid having dccps_epoch in
dccp_sock we might as well get rid of dccps_timestamp_time and
dccps_timestamp_echo, shifting it to some other struct that would be
inserted on any CCID that wants to use these timestamping.

Checking RFC4341 (CCID2):

   6. The sender estimates round-trip times, either through keeping
      track of acknowledgement round-trip times as TCP does or through
      explicit Timestamp options, and calculates a TimeOut (TO) value
      much as the RTO (Retransmit Timeout) is calculated in TCP.  The TO
      determines when a new DCCP-Data packet can be transmitted when the
      sender has been limited by the congestion window and no feedback
      has been received from the receiver.

Nah for now I'll merge your patches as is and do some testing this time around.

- Arnaldo
