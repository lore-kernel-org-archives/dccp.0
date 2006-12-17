From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Sun, 17 Dec 2006 21:55:12 +0000
Subject: Re: [PATCH] BUG-FIX - conversion errors
Message-Id: <4585BCC0.9050708@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200612081532.21104@strip-the-willow>
In-Reply-To: <200612081532.21104@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

FYI, you're right, Gerrit: CCIDs 2 and 3 don't mention CCMPS because for 
those CCIDs, CCMPS=\infty.  CCID 4, when defined, will impose a CCMPS.

Eddie


Gerrit Renker wrote:
> |  > |  Do we calculate mss anywhere?
> |  > Yes there is support in dccps_mss_cache .
> |  > At the begin of dccp_send_msg e.g. it is used. 
> |  
> |  Yup, look at dccp_sync_mss() used in dccp_connect_init():
> 
> <snip>
> 
> Thank you for the helpful `pointers' :)  - I was amazed a couple of months ago
> about how much of that code is active and quietly doing its job with accuracy. 
> 
> 
> |          /*
> |           * FIXME: this should come from the CCID infrastructure, where,
> |           * say, TFRC will say it wants TIMESTAMPS, ELAPSED time, etc,
> |           * for now lets put a rough estimate for NDP + TIMESTAMP +
> |           * TIMESTAMP_ECHO + ELAPSED TIME + TFRC_OPT_LOSS_EVENT_RATE +
> |           * TFRC_OPT_RECEIVE_RATE + padding to
> |           * make it a multiple of 4
> |           */
> |  
> |          mss_now -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
> |  
> I thought that when we are actively using the provided MSS facilities, then there
> is more incentive to tackle this one above too.
> 
> 
> 
> |  Infrastructure wise I guess struct ccid_operations should have a...
> |  lemme read the relevant part of 4340... there CCMPS:
> |  
> |  ----------------- 8< -------------
> |  14.  Maximum Packet Size
> |  
> |     A DCCP implementation MUST maintain the maximum packet size (MPS)
> |     allowed for each active DCCP session.  The MPS is influenced by the
> |     maximum packet size allowed by the current congestion control
> |     mechanism (CCMPS), the maximum packet size supported by the path's
> |     links (PMTU, the Path Maximum Transmission Unit) [RFC1191], and the
> |     lengths of the IP and DCCP headers.
> |  ----------------- 8< -------------
> I don't know how often I read through 4340, 4341 and 4342 trying to find out what `CCMPS'
> is for - it seems that in CCID2 and CCID3 it is both set to `infinity', at least I can
> find no explicit mention in 4341/4342 of CCMPS.
> 
> But for the MSS caching a `ccid_mps' member would be useful anyway for the above required purpose.
> 
> This in turn re-opens other questions - in CCID3 e.g. feedback packets should always contain
> also a Loss Intervals option - which is still missing in CCID 3. 
> 
> It is good that you raise this; I put a copy into my ToDo folder and will ask around in some time
> if anyone is working on it. If no one else does it I will give it a try at some time, but am bogged
> down by other work. I am re-working the CCID `larger initial windows' patch at the moment, plus
> sequence number issues. 
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
