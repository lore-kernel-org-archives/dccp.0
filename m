From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 19 Apr 2008 20:42:32 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804192242.33632.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Friday 18 of April 2008, Gerrit Renker napisa=B3:
> | > There is a more serious problem here: apparently no one tried to
> | > compile the `qpolicy' subtree since the changes on Monday. It fails
> | > with the BUILD_BUG_ON.
> | >
> | > I tried yesterday evening and found that there is not even a
> | > possibility of adding a single field to struct dccp_skb_cb: with the
> | > addition of the inet{,6}_skb_parm, the struct has reached its maximum
> | > size of 48 bytes (try printk("%u", sizeof(struct dccp_skb_cb));).
> | >
> | > There is a solution to this, will post a revised patch shortly.
> |
> | What you proposed in the patch should work ok for qpolicies for now. But
> | sooner or later the need to add a field to struct dccp_skb_cb will aris=
e.
> | So maybe we should think about it now...
> | Other possibility apart from what you proposed in the patch is creating
> | struct dccp_skb_cb_ext, move to it some fields from struct dccp_skb_cb
> | and in struct add a pointer to this new struct dccp_skb_cb_ext. Ok, may=
be
> | it is not the prettiest idea but in case somebody needs yet another
> | additional field in struct dccp_skb_cb_ext it would be nice to have an
> | idea how to do it.
>
> When the patch failed to compile I thought about those alternatives.
> Trying to extend the dccp_skb_cb over and above what is in there will be
> messy, since the IPv4/v6 parameters are required by other subsystems.
>
If inet{,6}_skb_parm is used only outside DCCP code then why at all should =
it=20
be placed in struct dccp_skb_cb taking up quite a lot of valuable space? Wh=
y=20
not put it directly in struct sk_buff? Especially that it is present in=20
struct udp_skb_cb, struct tcp_skb_cb as well.

> | > With regard to your point above: I think there is a way of keeping the
> | > framework open without bending over backwards to ensure the binary
> | > compatibility.
> |
> | While we are developing in the test tree compatibility is not important
> | at all. But real world needs compatibility, especially if it's not that
> | expensive. Otherwise people will get weird behaviour without any messag=
es
> | indicating what is wrong. And it's certainly not how code should be
> | written. It can't be that binary package of VLC (or any other streaming
> | server) cannot use newer kernel version because we added a new field.
>
> True, but we need to get something working first. There is no point
> exporting an API which only works half.
>
You can never assume that the API is feature complete. Even if it "works ha=
lf"=20
at the beginning (which is I guess quite normal) it should be easy to make =

it "work full" without breaking compatibility when it's not necessary.

> In this regard, another problem with the patch has arisen: the type of
> passing priority information will not work on 64-bit architectures in
> compatibility mode.
>
> Thanks to an answer by David Miller I found this out today. You can
> verify this problem by running the patch e.g. on a sparc64 system: no
> packets will be sent, sendmsg() returns with EINVAL.
>
I don't have any 64 bit system at hand...
Does David's suggestion mean that changes are only required in userspace=20
application or on the kernel side as well?

> | > My question for you in this regard: which policy can you think of who=
se
> | > priorities/preferences can not be mapped into an unsigned 32-bit
> | > integer? I think that such a number is sufficiently expressive enough
> | > to cater for a wide range of policies. It can be interpreted as
> | >  * symbolic value (enum)
> | >  * ascii string (similar to DCCP service code)
> | >  * millisecond timeout (with room for up to 7 weeks)
> | >  * microsecond timeout (with room for up to 1.19 hours)
> | >  * priority values (the large range 0..2^32-1 can be partitioned)
> | >  * ... ?
> |
> | Putting any of those values in an integer is pretty straightforward. But
> | when you want to put both timeout and priority things get messy. Would =
it
> | be possible at least to use structure like that:
> | struct dccp_packet_info
> | {
> | 	s8	priority;
> | 	u16	timeout_mantissa:10;
> | 	u16	timeout_exponent:6;
> | }
> | ? That would still fit in 32-bit integer (so could be stored in
> | skb->priority), but would provide a much cleaner interface.
> | --
>
> Yes that is possible. It need not be a struct, the same effect can be
> achieved with bit shifts and bitmasks (this is the way the Ack Vectors
> are encoded).
>
Yes, it can be achieved by bit operations. But to me a structure is a much =

cleaner way. And that is especially important when designing interfaces.=20
Final effects should be the same but when using structure it is the compile=
r=20
that takes care of low level bit operations.

> Semantically there is no restriction of what the u32 number represents. A=
nd
> it is a large space. I don't think that a larger size is required.
>
Ok, for now 32 bits are enough and I can't think of the need to use more bi=
ts.=20
I wouldn't be so sure about future though. But ok, if it turns up that we=20
need more space in the future then we will see, there is no need to worry=20
about it now. We can indeed assume 32 bits for now.
--=20
Regards,
Tomasz Grobelny
