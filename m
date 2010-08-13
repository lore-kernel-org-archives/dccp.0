From: Samuel Jero <sj323707@ohio.edu>
Date: Fri, 13 Aug 2010 20:40:25 +0000
Subject: Re: Problems with idle DCCP connections
Message-Id: <1281732025.10297.413.camel@sjerolaptop.homelinux.net>
List-Id: <dccp.vger.kernel.org>
References: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
In-Reply-To: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I finally got the testing tree build and running yesterday. In running
my tests on it today, I discovered, to my surprise, that the problem I
was having with DCCP clamping down on the sending rate after idle
periods is not present in either CCID-2 or CCID-3 of the testing tree
from 8/11/2010.

I do, however, see a bunch of messages like the following
in /var/log/messages when using CCID-3: "dccp_sane_rtt: RTT sample
8644424 out of bounds!"

> Could I thus ask you to pull 
>       git://eden-feed.erg.abdn.ac.uk/dccp_exp  [subtree 'dccp']
> 
> once again and retry with CWV (it is the ccid2_do_cwv module parameter,
> per default it is on)? To me it seems likely that this could be helpful
> for what you are trying to do.

I will pull the current tree and double check it; however, my problem
(or at least the symptoms) appears to be fixed without CWV. I'll let you
know how the new tree works by Monday or Tuesday.

Thank you for your help.

Samuel Jero

