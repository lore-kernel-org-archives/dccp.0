From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Mar 2008 10:12:47 +0000
Subject: Re: packet priorities
Message-Id: <20080308101247.GA4843@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Tomasz,

| The next step would be to use it in VLC stream_out module to make for example 
| sound more important (and thus more likely to arrive to destination 
| endpoint). I played a bit with VLC code and it seems it would be possible 
| (some MPEG Transport Stream packet reordering will be necessary). 
I have some doubts whether VLC is useful - as far as I know all
video/audio/subtitle data is internally packaged into a single MPEG-2
transport stream, so it is not possible to separate/prioritise its parts.

Which version of VLC did you use? I haven't tried, but Remi posted
earlier on this list that the SVN version of VLC comes with quite
sophisticated DCCP support (including SDP announcements).
I am still using my old (f)ugly hack from
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#VLC_Patch
but still want to check out Remi's code.

A better starting point is mpeg4ip, but it is a chicken-and-egg problem
as there are no DCCP-enabled servers yet.

| Prioritizing sound over video should be especially useful in video 
| conferencing but for now I'm not going to implement it. That's simply because 
| I'm afraid that testing conditions could be highly variable and difficult to 
| reproduce. Let's stick to something predictable for now.
I could not agree more, this will just lead to entanglements.
Two ideas with regard to reproducing:
 1. The excellent little D-ITG traffic generator
    http://www.grid.unina.it/software/ITG/
    It has DCCP support and packet timing can be set as a random variable,
    which can be bound to a random seed (to reproduce test runs).
 2. For a more realistic approach of video streaming, the trace collection on 
    http://trace.eas.asu.edu/tracemain.html
    could be useful since it provides inter-packet gap data from real streams.

 
| > The problem is that the socket API is "weird": a TCP/UDP socket would
| > simply block until one can send a packet. DCCP may block because it is
| > doing congestion control. Currently the difference to normal sockets API
| > is that Linux DCCP uses a type of "port" (in operating systems terms):
| > the application can fill this port with data until it is told "EAGAIN"
| > (port busy).
| > This is insufficient for real-time data (which may become too old) and
| > I am guessing that this is where your prioritisation ideas come in.
| >
| That's exactly the thing I asked about some time ago in "dccp send" thread. It 
| then turned out that discarding a packet is possible. But to choose 
| effecively (ie. quickly) a packet to discard might not be so easy... And I 
| need to give it a thought as it may spoil a bit my time complexity 
| estimations.
Does your scheme use timeouts for packets? If yes, then part of the
question is already solved. I can't say what happens with abstract
priorities, I am assuming you would like to establish a partial ordering
among the packets, in the way of "if you need to discard packets since
the link is congested, throw away all packets with priority < P away, if
that is not possible, tell the application"?


 
| >  2. There was an early implementation by Lai/Kohler
| >     http://www.cs.ucla.edu/~kohler/pubs/lai04efficiency.pdf
| >     but this is more of a conceptual model, as it shares memory regions
| >     between kernel and user space. The only way I can see of
| >     implementing this would be mmap() with additional primitives to
| >     protect the shared areas. Maybe there is a smarter way.
| >     This used a 2-priority scheme: enqueued packets are either `live'
| >     or `dead'; and the application can modify packets it already
| >     enqueued.
| >
| I've seen it some time ago but find it too complex. Not only to implement in 
| kernel but especially to application developers. What I prefer is "fire and 
| forget" style. Of course the approach may be quite flexible but I doubt it's 
| worth it.
Yes I have exactly the same problem with this. It may be worth keeping an eye
on it, but it requires to solve several many things in many places. 
Someone actually implemented this API for TCP in Linux 2.6.15.4 (not mainline):

  Birkedal, Erlend. Late data choice with the Linux TCP/IP stack.
  MSc thesis, Department of Informatics, University of Oslo, 24/5/2006.
  http://home.ifi.uio.no/paalh/students/ErlendBirkedal.pdf

And indeed - it required a kernel module plus a userspace library. In
addition, there is the need to protect the memory areas from illegal
access, and to synchronise the umod_i and kern_i pointers. The problems with
the API are summarised in section 4.2.4 of that thesis and a careful
note in section 6.3 hints that for a mainline kernel patch more work
can likely be expected.



| > | 4. How fast should it be in terms of computational complexity? Is O(n)
| > | acceptable, where n is the number of packets in queue? Or should I make
| > | it O(m), where m is number of priorities in currently in queue? Or should
| > | I think of something faster?
| >
| > This is a good thought, for me the question "what is communicated and
| > how" is almost as important.
| >
| I'm afraid I don't understand you well here.
And it was not very well expressed. I didn't understand what problem you
are solving with the priorities. My understanding of the problem is at a
simpler level, I am interested in allowing to time out packets for 
time-critical data.

What I meant to say is how the API interface should be changed (i.e. what
to tell the kernel), which is the same point as at the end of the email.

 
| > | 5. Should the number of packet priorities be hard limited? I can't
| > | imagine using more than 8 bands, so maybe limiting to about 16 different
| > | priorities would be ok?
| >
| > It would be great if the design would allow different types of policies,
| That would involve designing an interface a policy should implement. I'll 
| think about that. But what first comes to mind are 4 functions: init, 
| enqueue, dequeue, destroy.
| Should policies be available as separate kernel modules in the same fashion as 
| ccids?
This is a very good thought and it is a good idea to keep the design
modular and generic. But modules and policies are not an end in itself,
my question is - what would be the simplest-possible interface to
implement and how would it generalise?

With regard to your point (5), Ian was also using a band of priorities.
In http://wand.net.nz/~iam4/dccp/patches20/30-best_packet_next.diff,
there is this abstraction:

	struct dccp_prio {
	       struct timeval expiry;
	       u16 priority;
	       u16 method;
	};


When priority = 0 then conventional sending is done (enqueue at tail),
otherwise the `method' field allows different interpretations of the
priority field.

By the way, the idea of setting a "time-to-live" for the packet is not
new, it is used in the partial reliability extension of SCTP (PR-SCTP),
described in RFC 3758. I haven't checked the SCTP code, but this seems
a very good area to have a look.



| > | 6. Packets with lowest priorities should be discarded so as not to exceed
| > | configured queue length.
| >
| > I am interested to make this more precise, since this is exactly the
| > problem which currently happens in applications:
| >  * media servers which need to serve a streaming packet before a given
| >    deadline
| The deadline is not that easy to determine due to client side buffering. At 
| least that would require cooperation on receiving side. For now I just assume 
| that some packets are simply more important than others. That is they convey 
| more information to the one who is watching. When streaming football match 
| you are probably less interested in voice comments, music and applause and 
| more about "where is the ball?" (video more important). But when watching the 
| news usually audio is much more important than the object on video that 
| you've already seen thousands of times.
The same problem came up in Erlend Birkedal's thesis: the conclusion
there was that the prioritisation scheme can not avoid that some packets
arrive too late at the receiver.
So I guess we can split the problem and worry about the receiver side later.

The example of football streaming is good. The problem really stretches
across several layers:
 * the user-perceived output (MOS, ITU-T E-model of perceived quality)
 * the application which streams/receives the data
 * the socket layer which is controlled by the application
 * the transport layer which is controlled by the kernel and which is
   influenced by congestion and current network parameters.

And I think your work targets all three last points.

I am interested in seeing at least a subset of Ian's work realised and I
am also interested in your plans. My time is a bit constrained at the
moment, as I am currently still stuck with fixing some existing CCID-2 bugs.
