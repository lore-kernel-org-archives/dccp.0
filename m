From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 20 Feb 2012 03:45:26 +0000
Subject: Re: [PATCH] Allow Acknowledgment of all valid Response packets
Message-Id: <20120220034526.GA23017@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4F33555B.6070607@ohio.edu>
In-Reply-To: <4F33555B.6070607@ohio.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Samuel,

apologies for the late reply, there were some changes in the mail system that
lead to being offline last week.

Thank you for the patch. What I am asking myself is whether the problem is
 * specific to links with a long RTT or
 * can be used in general for all links?

I believe the patch is useful, but am not sure using it for the general case,
need to work through the implications. Also the patch did not apply due to 
line-wrap, I tried to fix this manually but there were several places.

The 'increase ISS on retransmission' issue was first discovered 2006 by Vladimir,
  http://www.mail-archive.com/dccp@vger.kernel.org/msg00710.html

Also, there are other things in DCCP that currently will not work well over long-delay links:
 * DCCP_TIMEOUT_INIT of 3 seconds (you mentioned this already in your email)
 * DCCP_SANE_RTT_MAX = 3 seconds  (only used by ccid3/4)

I wonder thus if it makes sense to introduce a compilation flag "DCCP_LONG_DELAY_LINKS"
which changes these parameters and which would conditionally enable your patch?

Gerrit

