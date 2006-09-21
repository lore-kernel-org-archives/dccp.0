From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 21 Sep 2006 03:22:59 +0000
Subject: Packet size s on CCID3
Message-Id: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have been discussing the packet size s for CCID3 (TFRC) with my
supervisor and also been discussing related issues with Gerrit and I
am wondering why we have this?

CCID3 is datagram based and the whole point of s is to keep packets at
a certain rate per second. In effect provided s is calculated
correctly it cancels out of the equation but it becomes more
complicated in the code! If it is miscalculated (accidentally or
deliberately) it becomes worse because you are either starved or send
too much.

Why not just calculate a packet rate per second? Or am I missing
something obvious?

I'm looking to apply this in other areas of implementation as well -
for example packet buffering in TCP is traditional done with a limit
of bytes where DCCP would make more sense to limit this on number of
packets - and the code would be much easier too.

Calculating on packets per second also has the effect that it is
visible to application designers potentially who will put more data in
a datagram to increase throughput.

Comments?

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
