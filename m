From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 22 Aug 2007 08:31:13 +0000
Subject: Re: [PATCH 2/3]: Provide 10s of microsecond timesource
Message-Id: <200708220931.13786@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708212000.16659@strip-the-willow>
In-Reply-To: <200708212000.16659@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > [DCCP]: Provide 10s of microsecond timesource
|  > 
|  > This provides a timesource, conveniently used for DCCP timestamps, which 
|  > returns the elapsed time in 10s of microseconds since initialisation. 
|  > This makes for a wrap-around time of about 11.9 hours, which should be
|  > sufficient for most applications.
|  
|  Why do it at kernel boot (or at dccp module load time to be more
|  precise)? Why not do it at sock creation time? Then it will be 11.9
|  hours after the socket is created.
|  
|  This is how dccps_epoch was used BTW :-)
This was done intentionally to keep it small. I figured that if there are e.g.
60 sockets, then each of them needs a ktime_t variable, plus an initialisation
(and another one for child sockets); and then it may be that the dccp_timestamp()
is never called: currently the only customer of dccp_timestamp() is CCID3 (for
the SYN RTT sample). If CCID2 is used, then all this is provided but not used.
Hence, for the occasional timestamp keeping it separate comes at a lower cost.

Actually, the problem is not like the sequence number arithmetic, since normal
subtraction (not modulo-2^32 subtraction) is used, i.e. if the socket is created
5 seconds before the 32-bit value wraps around, then 5 seconds later the time
difference to an earlier timestamp would reach a huge value (2^32 - 1 - 5 seconds).

To avoid this problem, one would have to use modulo-2^32 subtraction, ie. cast to
s64 and see if the difference is negative, and add 2^32 if it is.

But this all seems to me over-engineering: the problem occurs only every 11.9 hours,
and if it occurs earlier, it is caught by dccp_sample_rtt() which will reduce the 
huge value to 3 seconds (max RTT).

And it is once again CCID3 which causes these headaches with its dependence on precision.

I can see the following alternatives, what is your stance regarding:
 (a) keep as it is (probably not agreeing due to this email?)
 (b) keep principle, but use at socket creation (glitch comes possibly later, but will still occur)
 (c) ditch principle and use even lower granularity - milliseconds (jiffies seems like a natural match)

My personal favourite is (c).
	
