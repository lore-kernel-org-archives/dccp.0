From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 07 Mar 2008 10:51:55 +0000
Subject: packet priorities
Message-Id: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I'd like to write a patch to kernel that would allow dccp packets to be sent 
according to priorities. There are a few things that might be worth 
discussing.
1. The patch should not change default kernel behaviour. That is prioritizing 
should be turned on explicitly not to break existing applications.
2. The mechanism should be CCID independent.
3. For now I plan to add only priorities. But I can imagine that other 
criteria might be useful (for example expiry times as proposed by Ian's 
experimental patch). This makes it necessary to think of a way to specify 
queuing and dequeuing method. Should it be set per socket or per packet?
4. How fast should it be in terms of computational complexity? Is O(n) 
acceptable, where n is the number of packets in queue? Or should I make it 
O(m), where m is number of priorities in currently in queue? Or should I 
think of something faster?
5. Should the number of packet priorities be hard limited? I can't imagine 
using more than 8 bands, so maybe limiting to about 16 different priorities 
would be ok?
6. Packets with lowest priorities should be discarded so as not to exceed 
configured queue length.

Would such a patch be accepted in mainline kernel? Of course after discussing 
the ideas and implementation details. Thanks in advance for your input,
-- 
Regards,
Tomasz Grobelny
