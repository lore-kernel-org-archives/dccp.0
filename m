From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Nov 2006 20:02:35 +0000
Subject: [BUGS] Two bugs found
Message-Id: <5640c7e00611301202t34643e2fndb0d782569f04dc5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

To let you know of two bugs I've observed in my logs (in case others
see easy answers):

Bug 1 - always with RESET packet and note P.seqno!
Nov 22 15:38:23 localhost kernel: [65275.357482] DCCP: Step 6 failed
for RESET packet, (LSWL(319010713595) <= P.seqno(10) <S.SWH(319010721094)) and (P.ackno exists or LAWL(931392870355) <P.ackno(931392870591) <= S.AWH(931392870597), sending SYNC...
Nov 22 15:38:28 localhost kernel: [65280.194139] printk: 139 messages
suppressed.
Nov 22 15:38:28 localhost kernel: [65280.194179] DCCP: Step 6 failed
for RESET packet, (LSWL(319010713595) <= P.seqno(10) <S.SWH(319010721094)) and (P.ackno exists or LAWL(931392870355) <P.ackno(931392870755) <= S.AWH(931392870761), sending SYNC...
Nov 22 15:38:33 localhost kernel: [65285.209823] printk: 181 messages
suppressed.
Nov 22 15:38:33 localhost kernel: [65285.209863] DCCP: Step 6 failed
for RESET packet, (LSWL(319010713595) <= P.seqno(24) <S.SWH(319010721094)) and (P.ackno exists or LAWL(931392870355) <P.ackno(931392870962) <= S.AWH(931392870968), sending SYNC...

Bug 2:
Pretty sure this is to do with tx_bufferig and closing out a connection.
Nov 22 15:45:31 localhost kernel: [65702.725265] KERNEL: assertion
(skb_queue_empty(&sk->sk_write_queue)) failed at net/core/stream.c
(276)

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
