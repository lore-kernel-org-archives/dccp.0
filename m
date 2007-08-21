From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 13:25:27 +0000
Subject: Re: [PATCH 13/15] [DCCP] options: convert dccp_insert_option_timestamp to ktime_t
Message-Id: <200708211425.27664@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070819235240.GQ24792@ghostprotocols.net>
In-Reply-To: <20070819235240.GQ24792@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorry this one has a bug also - it compresses a signed 64 bit quantity into a 32-bit unsigned
value. When re-interpreted as microsecond value (in dccp_sample_rtt), this gives values which
are way too small.

Maybe we should keep the dccp_epoch thing, but now with ktime_t, so as to avoid large microsecond values?

In any case, the RTT sampling is not usable - it constantly produces overflow, since the timestamp
option value is too small.

Please see below.

|  @@ -388,11 +388,7 @@ EXPORT_SYMBOL_GPL(dccp_timestamp);
|   
|   int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
|   {
|  -	struct timeval tv;
|  -	__be32 now;
|  -
|  -	dccp_timestamp(sk, &tv);
|  -	now = htonl(timeval_usecs(&tv) / 10);
|  +	__be32 now = htonl(((suseconds_t)ktime_to_us(ktime_get_real())) / 10);
|   	/* yes this will overflow but that is the point as we want a
|   	 * 10 usec 32 bit timer which mean it wraps every 11.9 hours */
|   

I debugged this by adding 

int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
{
       ktime_t time = ktime_get_real();
       s64 n = ktime_to_us(time);
       u32 now;

       do_div(n, 10);
       now = n;

       printk("TIME: %lld => us = %lld => %u (%x) ", (long long) time.tv64, (long long)n, now, now);
       now = htonl(now);
       printk(" = %x\n", now);
}

... and I get values such as
   TIME: 1187701891935389887 => us = 118770189193538 => 1458557250 (56efd142)  = 42d1ef56

This is the cut-off, the `us' value is 
  6C0556efd142 and the u32 (__be32) converted value is
      56efd142

So this doesn't work - in CCID3, due to the large RTT values, the sending rate currently goes down
to 7..8 kbits/sec - when I change the RTT back to normal, the rate goes back to line speed (91.6 Mbits/sec).


