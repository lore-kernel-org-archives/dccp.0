From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 07 Mar 2008 15:49:09 +0000
Subject: Re: packet priorities
Message-Id: <20080307154909.GF9295@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| I'd like to write a patch to kernel that would allow dccp packets to be sent 
| according to priorities. There are a few things that might be worth 
| discussing.
Excellent - you have actually hit on a major problem which is still
unresolved in the API.

This has wider scope and thus is important to resolve. You didn't write
for which purpose you wanted to use priorities, but the concept of
keeping the prioritisation scheme is very good.

The problem is that the socket API is "weird": a TCP/UDP socket would
simply block until one can send a packet. DCCP may block because it is
doing congestion control. Currently the difference to normal sockets API
is that Linux DCCP uses a type of "port" (in operating systems terms):
the application can fill this port with data until it is told "EAGAIN"
(port busy). 
This is insufficient for real-time data (which may become too old) and
I am guessing that this is where your prioritisation ideas come in.								      

The only existing approaches I know of are
 1. Ian's patches which communicate an expiry time to the kernel
    http://www.wand.net.nz/~iam4/
    Ian keeps his best-packet-next algorithm as an experimental patch set,
    but I can see useful points - in particular the idea of passing the
    expiry time as ancillary data (cmsghdr).
 2. There was an early implementation by Lai/Kohler
    http://www.cs.ucla.edu/~kohler/pubs/lai04efficiency.pdf
    but this is more of a conceptual model, as it shares memory regions
    between kernel and user space. The only way I can see of
    implementing this would be mmap() with additional primitives to
    protect the shared areas. Maybe there is a smarter way.
    This used a 2-priority scheme: enqueued packets are either `live'
    or `dead'; and the application can modify packets it already 
    enqueued.

My feeling is that, while worth exploring, (2) is more complex to
implement (mmap() call), but is in principle interesting. 

Therefore I think that your idea and Ian's approach are better feasible.
It may take some iterations to make the API fully usable, but it is time
to start this. I agree with many of your points, comments below.
    

| 1. The patch should not change default kernel behaviour. That is prioritizing 
| should be turned on explicitly not to break existing applications.
I'd even say it could risk to break existing applications, since the API
is not a particular good one at the moment.

| 2. The mechanism should be CCID independent.
Yes.
| 3. For now I plan to add only priorities. But I can imagine that other 
| criteria might be useful (for example expiry times as proposed by Ian's 
| experimental patch). This makes it necessary to think of a way to specify 
| queuing and dequeuing method. Should it be set per socket or per packet?
For the queuing method changing the policy on a per-packet basis means a
lot of overhead, so a per-socket policy seems reasonable.

| 4. How fast should it be in terms of computational complexity? Is O(n) 
| acceptable, where n is the number of packets in queue? Or should I make it 
| O(m), where m is number of priorities in currently in queue? Or should I 
| think of something faster?
This is a good thought, for me the question "what is communicated and
how" is almost as important.

| 5. Should the number of packet priorities be hard limited? I can't imagine 
| using more than 8 bands, so maybe limiting to about 16 different priorities 
| would be ok?
It would be great if the design would allow different types of policies,
i.e. "earliest-packet first", the limit of priorities can also be
configured via a Kconfig option, so it is not a big deal.

| 6. Packets with lowest priorities should be discarded so as not to exceed 
| configured queue length.
I am interested to make this more precise, since this is exactly the
problem which currently happens in applications: 
 * media servers which need to serve a streaming packet before a given 
   deadline
 * traffic generators such as D-ITG which likewise need to "get a packet
   out" within a given time bound (they have pre-computed inter-packet
   gaps which are determined as random variables).


| Would such a patch be accepted in mainline kernel? Of course after discussing 
| the ideas and implementation details. Thanks in advance for your input,
This depends on Arnaldo's decision. From experience, experimental or new
features take a little longer, but this should by no means be a discouragement.

In the meantime, I would be more than happy to allocate space and/or a tree on
as part of the test tree,
http://www.linux-foundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tree

which would be kept in synch with the netdev tree.


Thanks for the input
Gerrit
