From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 29 Nov 2006 22:13:30 +0000
Subject: Revised iperf patch
Message-Id: <5640c7e00611291413x69e6b2cawb65af02152954d5c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

I have revised the iperf patch I maintain to work with latest DCCP
Linux codebase. (basically coping with EAGAIN)

As a reminder this also allows setting of TCP congestion control method also.

Can someone update the iperf webpage as this points to an outdated patch.

Patch is at:
http://wand.net.nz/~iam4/software/congestion-iperf-2.0.2-2.diff

For dccp users I have also updated my DCCP page a little at:
http://wand.net.nz/~iam4/dccp/

Regards,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
