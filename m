From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Fri, 23 Jun 2006 08:46:19 +0000
Subject: Re: HOWTO profile CCID2
Message-Id: <20060623084619.GE2501@c3po.0xdef.net>
List-Id: <dccp.vger.kernel.org>
References: <20060622222323.GA2291@shorty.sorbonet.org>
In-Reply-To: <20060622222323.GA2291@shorty.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

* Andrea Bittau | 2006-06-22 23:23:23 [+0100]:

>* To simplify the process, I coded profiler.c which will poll getsockopt() on a
>  socket and log info on a file.

Did this polling fetch all information - or can it happend that is miss some
iterations?

>* libintr will intercept library calls which create DCCP sockets.  When a DCCP
>  socket is created, it will be sent to the profiler so that it can monitor it.
>  This allows you to monitor the sockets created by a program [such as iperf]
>  without having to screw with its code.

;-) nice!

HGN


-- 
It's  the  good  girls  who keep the diaries, the bad girls never
have the time.  
                                             -- Tallulah Bankhead
