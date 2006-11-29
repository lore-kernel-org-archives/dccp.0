From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 29 Nov 2006 23:04:03 +0000
Subject: [BUG] CCID3 no longer works!
Message-Id: <5640c7e00611291504v60e06067h469e8c91293031c9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

I've started my testing and confirm what the other two have said on
list. Using Acme net 2.6.20 tree as of about four hours ago basically
I get no data transmitted. Works fine on my 2.6.19 modified tree.

I'm using iperf as follows (using today's iperf patch)
ian@jandi3:~$ iperf --protocol dccp -s -l 500
ian@jandi1:~$ iperf --protocol dccp -c jandi3 -l 500 -t 20

There are some clues at least on jandi3 log:
Nov 30 11:57:49 localhost kernel: [  645.677995]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Nov 30 11:57:49 localhost kernel: [  645.678678]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent

Will start by look at that patch and if necessary then start bisecting.

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
