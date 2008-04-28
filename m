From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 28 Apr 2008 21:03:40 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804282303.40673.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 28 of April 2008, Gerrit Renker napisa=B3:
> | (a bit of reordering)
> |
> | > So we can reduce this to the other question "is 32 bit enough for
> | > priority information".
> |
> | That is an important question. But I'm afraid the answer is no (even
> | though I thought otherwise when writing previous mail). When we want to
> | add packet expiry times we will need a field for timestamp. Which is
> | quite big (64 bits?). But note that it is only needed for in-kernel
> | implemetation. Userspace can write this information on as low as 16 bit=
s.
> | This leads me to conclusions stated below.
>
> I had the same thoughts - it is easy to end up with a wide range of
> possible structs, numbers, etc. that are not related and require 20
> different APIs.
For now I can think of three possible solutions:
a) one structure per policy (of course only if additional data is needed),
b) one structure that could contain parameters from all possible policies=20
(that would mean that not all fields are used),
c) allow qpolicy to use each cmsg header as different parameter. So that ap=
art=20
from DCCP_SCM_PRIORITY we could also have DCCP_SCM_TIMEOUT_MS. And this see=
ms=20
to be a very nice approach. It has several advantages:
 - extensible,
 - application does not need to pass parameter if it is ok with default val=
ue.=20
It could for example pass only DCCP_SCM_TIMEOUT_MS without DCCP_SCM_PRIORIT=
Y,
 - it is easy to maintain compatibility.
This series of parameters should be parsed by specific qpolicy that can mak=
e=20
use of them (read: prio). Other policies (read: simple) would not even=20
attempt to parse the list of parameters.

> But the basic line of thought is
>  * the queue size is always limited since afaik the amount of skbs that
>    can be queued depends on the socket's write memory (wmem);
Yes.

>  * hence a strict priority ordering can be done even with u8 (up to 255)
>    in not-too-extreme case
But note that it is not only about ordering but potentially also about when=
=20
(and if) packets should be dropped. And that may depend on many factors, no=
t=20
only ordering, but also current time, current speed, current rtt, etc.

> | So this could look like that:
> | Userspace application fills in a structure:
> | struct dccp_packet_info {
> | 	s8 priority; //as it is now
> | 	u16 expire_after; //up to 65s with 1ms accuracy
> | }
> | and passes it to sendmsg(..., struct dccp_packet_info pktinfo), which
> | passes it to qpolicy_push which passes it to qpolicy_prio_push which do=
es
> | the tricky stuff with CMSG and does:
> | skb->priority=3Dpktinfo->priority;
> | skb->tstamp=3Dnow()+pktinfo->expire_after;
> | (possibly other things that could potentially store data in dccp_skb_cb)
>
> I notice you have discovered another skb field that could be reused :)
Yes :-)

> | This would allow us to:
> | 1. Use existing skb fields in a clean way. I mean according to their
> | names (priority, tstamp).
> | 2. Have a clean userspace interface not affected by internal kernel
> |    implementation details.
> |
> | What do you think of such decoupling?
> | --
>
> Yes, great. The concept is good, it is some of the details that need
> some more work. In (2) you mention distributing the information among
> several skb fields. With regard to above comment, I think we need to do
> this with some care, to avoid interactions with other subsystems.
>
Sure.

> At the moment I have no concrete idea of how to implement a timeout-based
> policy ... probably this is something along the line of Ian's patches
> and what you sketched above.
>
I think that implementing timeouts should not be in separate policy but in =

prio policy. Simply one more parameter would have to be passed to this poli=
cy=20
and timed out packets would be dropped in qpolicy_prio_full() or=20
qpolicy_prio_push() methods. The master question for now is how to pass thi=
s=20
additional parameter. I would be in favour of second struct cmsg* with type=
=20
set to DCCP_SCM_TIMEOUT_MS.

> Also in (2) is the size question. The bottom line is if 2^32-1 different
> numbers are sufficient to represent a range of policies, then we can
> work with skb->priority for the moment.
>
> My understanding of the above is
>  * the per-policy data is an opaque bitstring whose only requirement
>    is that it fits within 32 bits;
>  * how the bitstring is interpreted depends on the chosen policy;
You mean data passed between userspace and kernelspace or in-kernel storage=
?=20
1. For user to kernel data for me seems to be not expressive enough. Who kn=
ows=20
what these 32-bits are supposed to mean? Ok, we may document that but to me=
=20
it is almost like passing void*: you never know what's inside.
2. For in-kernel storage 32-bits is simply not enough for priority+timeout.
--=20
Regards,
Tomasz Grobelny
