From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 16 Jun 2007 14:21:04 +0000
Subject: Re: [PATCH 2/6]: Provide fallback RTT value when none is available
Message-Id: <200706161521.05192@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091958.08037@strip-the-willow>
In-Reply-To: <200706091958.08037@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > [DCCP]: Provide fallback RTT value when none is available
|  > @@ -73,9 +73,12 @@ extern void dccp_time_wait(struct sock *
|  >
|  >  #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
|  >
|  > -/* bounds for sampled RTT values from packet exchanges (in usec) */
|  > +/*
|  > + * RTT sampling: sanity bounds and fallback RTT value from RFC 4340, section 3.4
|  > + */
|  >  #define DCCP_SANE_RTT_MIN      100
|  > -#define DCCP_SANE_RTT_MAX      (4 * USEC_PER_SEC)
|  > +#define DCCP_FALLBACK_RTT      (USEC_PER_SEC / 5)
<snip>

|  
|  I personally think this patch should include the changes where this
|  occurs in the code but I know these are in separate patches.
|  
I have just checked - the place it is actually used is indeed a bit later in the
change set, in receiver RTT sampling, it is here:
	http://www.mail-archive.com/dccp@vger.kernel.org/msg01868.html

+	if (hcrx->ccid3hcrx_rtt = 0) {
+		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
+		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
 	}

But this patch is also generic: RFC 4340 says that this value (which agrees with
TCP-like values) can be used wherever there is no fallback.
