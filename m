From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 22 Apr 2008 20:30:25 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804222230.25743.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 22 of April 2008, Gerrit Renker napisa=B3:
> | > | While we are developing in the test tree compatibility is not
> | > | important at all. But real world needs compatibility, especially if
> | > | it's not that expensive. Otherwise people will get weird behaviour
> | > | without any messages indicating what is wrong. And it's certainly n=
ot
> | > | how code should be written. It can't be that binary package of VLC
> | > | (or any other streaming server) cannot use newer kernel version
> | > | because we added a new field.
> | >
> | > True, but we need to get something working first. There is no point
> | > exporting an API which only works half.
> |
> | You can never assume that the API is feature complete. Even if it "works
> | half" at the beginning (which is I guess quite normal) it should be easy
> | to make it "work full" without breaking compatibility when it's not
> | necessary.
>
> No I don't agree. Things that work half are worse than constant failures,
> since it is never clear when they will fail next. But maybe you didn't me=
an
> that.
>
I mean that what we are currently discussing (only priorities) is in itself=
=20
useful ("works half"). Adding more features (expiry times) would be a nice =

but non essential feature ("work full").

(a bit of reordering)
> So we can reduce this to the other question "is 32 bit enough for priority
> information".
>
That is an important question. But I'm afraid the answer is no (even though=
 I=20
thought otherwise when writing previous mail). When we want to add packet=20
expiry times we will need a field for timestamp. Which is quite big (64=20
bits?). But note that it is only needed for in-kernel implemetation.=20
Userspace can write this information on as low as 16 bits. This leads me to=
=20
conclusions stated below.

> | > Semantically there is no restriction of what the u32 number represent=
s.
> | > And it is a large space. I don't think that a larger size is required.
> |
> | Ok, for now 32 bits are enough and I can't think of the need to use more
> | bits. I wouldn't be so sure about future though. But ok, if it turns up
> | that we need more space in the future then we will see, there is no need
> | to worry about it now. We can indeed assume 32 bits for now.
>
> So it only remains to see whether to use a field in dccp_skb_cb, or to
> use skb->priority. I think the latter has advantages, since this field
> is only set/used for the SO_PRIORITY field (in socket(7)).
>
I think we should distingish two things:
1. How do we pass data along with each packet from userspace to kernelspace.
2. How do we store data in in-kernel skb for internal use.
I'm afraid there was no such separation in my patches and mixing those two =

things causes a lots misunderstandings.

Ad 1. In this case we need not care about sizes etc. Clean and extensible=20
interface is very important. We can also have very different priority data =

representantion from what is later stored in skb.
Ad 2. In this case sizes do matter. We can use whichever fields we want. In=
=20
particular we need not keep all the data passed from userspace application =
in=20
one chunk but we can distribute it among arbitrary skb fields.

So this could look like that:
Userspace application fills in a structure:
struct dccp_packet_info {
	s8 priority; //as it is now
	u16 expire_after; //up to 65s with 1ms accuracy
}
and passes it to sendmsg(..., struct dccp_packet_info pktinfo), which passe=
s=20
it to qpolicy_push which passes it to qpolicy_prio_push which does the tric=
ky=20
stuff with CMSG and does:
skb->priority=3Dpktinfo->priority;
skb->tstamp=3Dnow()+pktinfo->expire_after;
(possibly other things that could potentially store data in dccp_skb_cb)

This would allow us to:
1. Use existing skb fields in a clean way. I mean according to their names =

(priority, tstamp).
2. Have a clean userspace interface not affected by internal kernel=20
implementation details.

What do you think of such decoupling?
--=20
Regards,
Tomasz Grobelny
