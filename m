From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 16 Nov 2007 13:39:56 +0000
Subject: Re: [PATCH 1/25] CCID-4 Kconfig and Makefile
Message-Id: <20071116133956.GA15774@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312018.36512.leandroal@gmail.com>
In-Reply-To: <200710312018.36512.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | > Suggestion: if CCID3 is not compiled as module, there will currently be
| > | > no TFRC debugging output for dccp_tfrc_lib when only CCID4 is enabled.
| > | > Something like
| > | >
| > | > config IP_DCCP_TFRC_DEBUG
| > | >         bool
| > | >         default y if IP_DCCP_CCID3_DEBUG || IP_DCCP_CCID4_DEBUG
| > | >
| > | > would enable this.
| > | >
| > | > On the other hand, the number of `debugs' keeps continually growing.
| > | > Maybe it is possible to just use tfrc_debug for everything that speaks
| > | > TFRC, otherwise we currently have
| > | >  * tfrc_debug   to enable debug messages in dccp_tfrc_lib
| > | >  * ccid3_debug            "                 dccp_ccid3
| > | >  * ccid4_debug            "                 dccp_ccid4
| > | >  * dccp_debug   to see the rest
| > | > -
<snip>
| 
| Then I will let this as it is and after we can working on this. Ok?
| 
Yes that's absolutely fine. I just checked: none of the trees
(origin|dccp|ccid4) currently uses tfrc_pr_debug(), so this is something
to be investigated when thinking of sharing code between ccid4/ccid3.

Either that macro / variable should then be obsoleted, or it could be
shared between CCID3/4.
-- 
