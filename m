From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Nov 2006 19:13:16 +0000
Subject: Fwd: [PATCH] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <5640c7e00611301113u2bdd0a4h589e25f0d65a30a6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

IETF mailing list,

I'm wondering if you'd like to comment on this as it seems to be a
real implementation issue - using TFRC on local lans (100 Mbits/sec, <
2 ms rtt) seems to cause high CPU load when doing testing using tools
such as iperf.

Is it worth considering having a minimum no feedback timer for the
spec as checking things this often is not so good and would definitely
hinder uptake on local boxes if we were being RFC compliant.

Thanks Gerrit for raising this.

Regards,

Ian
---------- Forwarded message ----------
From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Dec 1, 2006 2:18 AM
Subject: [PATCH] [DCCP]: Use higher timeout value for nofeedback timer
To: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>, Ian McDonald
<ian.mcdonald@jandi.co.nz>
Cc: DCCP Mailing List <dccp@vger.kernel.org>, Leandro Melo de Sales
<leandroal@gmail.com>, Burak Gorkemli <burakgmail-dccp@yahoo.com>


This is the patch which stops the nofeedback timer from spinning
every couple of microseconds, triggered by small RTTs.

However, there are a few more bugs in CCID 3; this is work in progress.

-----------------> Commit Message <-----------------------------------
[DCCP]: Use higher RTO default for CCID3

The TFRC nofeedback timer normally expires after the maximum of 4
RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
with a small RTT this can mean a high processing load and reduced
performance, since then the nofeedback timer is triggered very
frequently. As a result, the sending rate quickly converges towards
zero.

This patch provides a configuration option to set the bound for the
nofeedback timer, using as default the TCP RTO timeout of 1 second.

By setting the configuration option to 0, RFC 3448 behaviour can
be enforced for the nofeedback timer.

Has been tested to compile and work.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
