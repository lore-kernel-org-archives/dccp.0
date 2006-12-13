From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 13 Dec 2006 07:43:51 +0000
Subject: [BUG] CCID3 not compliant with RFC3448 5.2
Message-Id: <5640c7e00612122343xc4364e3u1624fcbdf660d2ca@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

In particular we are not determining if multiple packets lost in a row
are part of the same loss event.

This is evidenced in my test environment where we have machines about
1.5 msec apart (separated by a Linux router) and when running iperf we
lose 100 packets (which is another problem but not sure what is
causing it...). We get a loss interval for every single loss so we
quickly get an i_mean of 1 (or p of 1000000) which is not good.

The function that needs to be fixed is ccid3_hc_rx_detect_loss. This
code is a little nasty.

Just notifying the list for the record. I may or may not fix this but
it won't be this week.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
