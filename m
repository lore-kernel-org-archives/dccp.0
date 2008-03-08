From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 08 Mar 2008 00:41:02 +0000
Subject: Re: packet priorities
Message-Id: <200803080141.03117.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Friday 07 of March 2008, Gerrit Renker napisa=B3:
> | I'd like to write a patch to kernel that would allow dccp packets to be
> | sent according to priorities. There are a few things that might be worth
> | discussing.
>=20
> This has wider scope and thus is important to resolve. You didn't write
> for which purpose you wanted to use priorities, but the concept of
> keeping the prioritisation scheme is very good.
>
The next step would be to use it in VLC stream_out module to make for examp=
le=20
sound more important (and thus more likely to arrive to destination=20
endpoint). I played a bit with VLC code and it seems it would be possible=20
(some MPEG Transport Stream packet reordering will be necessary).=20
Prioritizing sound over video should be especially useful in video=20
conferencing but for now I'm not going to implement it. That's simply becau=
se=20
I'm afraid that testing conditions could be highly variable and difficult t=
o=20
reproduce. Let's stick to something predictable for now.

> The problem is that the socket API is "weird": a TCP/UDP socket would
> simply block until one can send a packet. DCCP may block because it is
> doing congestion control. Currently the difference to normal sockets API
> is that Linux DCCP uses a type of "port" (in operating systems terms):
> the application can fill this port with data until it is told "EAGAIN"
> (port busy).
> This is insufficient for real-time data (which may become too old) and
> I am guessing that this is where your prioritisation ideas come in.
>
That's exactly the thing I asked about some time ago in "dccp send" thread.=
 It=20
then turned out that discarding a packet is possible. But to choose=20
effecively (ie. quickly) a packet to discard might not be so easy... And I =

need to give it a thought as it may spoil a bit my time complexity=20
estimations.

> The only existing approaches I know of are
>  1. Ian's patches which communicate an expiry time to the kernel
>     http://www.wand.net.nz/~iam4/
>     Ian keeps his best-packet-next algorithm as an experimental patch set,
>     but I can see useful points - in particular the idea of passing the
>     expiry time as ancillary data (cmsghdr).
I already had a look at this patch and I also think that this is the right =
way=20
to pass this additional data to kernel.

>  2. There was an early implementation by Lai/Kohler
>     http://www.cs.ucla.edu/~kohler/pubs/lai04efficiency.pdf
>     but this is more of a conceptual model, as it shares memory regions
>     between kernel and user space. The only way I can see of
>     implementing this would be mmap() with additional primitives to
>     protect the shared areas. Maybe there is a smarter way.
>     This used a 2-priority scheme: enqueued packets are either `live'
>     or `dead'; and the application can modify packets it already
>     enqueued.
>
I've seen it some time ago but find it too complex. Not only to implement i=
n=20
kernel but especially to application developers. What I prefer is "fire and=
=20
forget" style. Of course the approach may be quite flexible but I doubt it'=
s=20
worth it.

> | 4. How fast should it be in terms of computational complexity? Is O(n)
> | acceptable, where n is the number of packets in queue? Or should I make
> | it O(m), where m is number of priorities in currently in queue? Or shou=
ld
> | I think of something faster?
>
> This is a good thought, for me the question "what is communicated and
> how" is almost as important.
>
I'm afraid I don't understand you well here.

> | 5. Should the number of packet priorities be hard limited? I can't
> | imagine using more than 8 bands, so maybe limiting to about 16 different
> | priorities would be ok?
>
> It would be great if the design would allow different types of policies,
That would involve designing an interface a policy should implement. I'll=20
think about that. But what first comes to mind are 4 functions: init,=20
enqueue, dequeue, destroy.
Should policies be available as separate kernel modules in the same fashion=
 as=20
ccids?

> | 6. Packets with lowest priorities should be discarded so as not to exce=
ed
> | configured queue length.
>
> I am interested to make this more precise, since this is exactly the
> problem which currently happens in applications:
>  * media servers which need to serve a streaming packet before a given
>    deadline
The deadline is not that easy to determine due to client side buffering. At=
=20
least that would require cooperation on receiving side. For now I just assu=
me=20
that some packets are simply more important than others. That is they conve=
y=20
more information to the one who is watching. When streaming football match =

you are probably less interested in voice comments, music and applause and =

more about "where is the ball?" (video more important). But when watching t=
he=20
news usually audio is much more important than the object on video that=20
you've already seen thousands of times.
--=20
Regards,
Tomasz Grobelny
