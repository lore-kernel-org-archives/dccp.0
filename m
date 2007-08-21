From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 18:58:50 +0000
Subject: [PATCH 0/3]: Follow-up patches for RTT sampling
Message-Id: <200708211958.50339@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I think I have a workable solution for the RTT samples and I have
tested it with success.
The concept is to use a dccp_epoch again, but to measure it in
units of `hundredths of milliseconds' (that is, 10s of microseconds).
This is native RFC 4340 format, with that the counter wraps around
every 11.9 hours - which should be more than enough for most DCCP 
applications. 

It splits into three patches, the first is a re-send:

Patch #1: Reuses ktime_get_real() for CCID3 - as sent earlier.
Patch #2: Provide 10s of microsecond timesource, this is the heart
          of the patch set, revives dccp_timestamp in a new format.
Patch #3: Demotes dccp_sample_rtt() to just to very simple tasks
          and does the remaining fixes for
	  * CCID3 SYN RTT
	  * all calls within ccid3.c

Tested it, works fine so far.
