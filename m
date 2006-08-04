From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Fri, 04 Aug 2006 11:25:54 +0000
Subject: High speed DCCP
Message-Id: <20060804112554.GA4791@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I coded an adaptor which allows CCID2 to use the existing Linux congestion
control code.  This means that we get vegas, reno, highspeed, etc. in DCCP for
free.  Here are some cwnd graphs of DCCP using this stuff:
http://darkircop.org/dccp/tcp/

If you're interested in reproducing these results let me know.

Anyway, this concludes my DCCP coding for a while.  I ran out of cwnd =D  I will
resume once I start getting acks from acme.
