From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Apr 2007 08:26:26 +0000
Subject: Re: [PATCH 4/25]: Cheaper & smaller timestamping
Message-Id: <200704020926.26151@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.22972@strip-the-willow>
In-Reply-To: <200703211844.22972@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > [DCCP]: Cheaper & smaller timestamping
  
|  A couple of comments though:
|  - this is how I had the code originally in many cases and Arnaldo
|  changed - can't remember why.
Arnaldo's code uses a reference point, the skb_get_timestamp() also did
that. May be useful against old incarnations across reboots.

|  - we should be looking at using the new ktime as monotonic but that
|  can be a task for another time.
Excellent idea, this may allow to make CCID3 more precise.

By sheer magic, skb_get_timestamp does this already, as I just saw:

static inline void skb_get_timestamp(const struct sk_buff *skb, struct timeval *stamp)
{
	*stamp = ktime_to_timeval(skb->tstamp);
}

so we only need to replace the do_gettimeofday() at some time.

I have another idea with regard to timestamps: the field
          dccp_inetconnection.icsk_ack.lrcvtime 
takes an __u32 timestamp - we could use this for the DCCP timestamp/timestamp echos,
which are 4 bytes (currently this is done for initial SYN RTT).

