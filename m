From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 07 Mar 2007 07:13:48 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <200703070713.49193@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Andre,

honestly, I have been unable to reproduce the bug, but there is a point
in what you said regarding the CCID-split patch. In fact, you identified
a real bug.

I have looked at your application:
 * the server listens, accepts and 
 * then writes to the client

This is bi-directional mode. In TCP no problem. In DCCP that patch
has disabled bidirectional mode since at that time there were
strange interactions.

In short: the only mode that is currently supported is
 * server listens, accepts
 * and only reads
 o client connects and
 o only writes

That works with the test applications (ttcp and iperf) since this is
exactly the way they operate. But it constrains socket programming.

I will ask Arnaldo to revert all these stupid changes that I caused.
This will allow full bidirectional connections in the first place. I
have looked at the CCID3 code, it seems to be ok with that.


Can you confirm that, when the `culprit' patch is reverted (as per
the first email), the bug disappears?

That would double the reasons.


In any way, thanks a lot for identifying this obvious restriction,
this has been a great help.

I think it is great that real applications appear and I would like to
use this paraslash application. If there are any other problems, please
do email to this list.

Thanks again
Gerrit
