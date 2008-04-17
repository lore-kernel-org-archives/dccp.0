From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 17 Apr 2008 20:03:07 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804172203.07758.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 16 of April 2008, Gerrit Renker napisa=B3:
> | > | | What happens if application is compiled with dccp_packet_info
> | > | | containing only one field (priority) and kernel containing two
> | > | | fields (for example priority and later added expiry time)? Wouldn=
't
> | > | | that implementation make extensions to dccp_packet_info impossibl=
e?
> | > |
> | > | Had not looked at it from this point of view. So you are suggesting
> | > |
> | > | 	if (msg->msg_control !=3D NULL && msg->msg_controllen >=3D sizeof(=
*dcp))
> | > | 		dcp =3D (struct dccp_packet_info *)msg->msg_control;
> | > |
> | > | instead? Agreed, point #1 to change in the patch.
> | >
> | > No, the above is nonsense. If the application uses an earlier version
> | > of the API, then it needs to be recompiled, there is no way it could
> | > pretend to have an adequate size.
> |
> | That would effectively stop development of any policy. And it's not abo=
ut
> | pretending the structure has different size, it's just about using only
> | the data that is provided by the application (even though it may be
> | incomplete).
> |
> | > So my take is that still the '=3D' is correct. But maybe this is a kn=
own
> | > problem?
> |
> | I can't see a problem with copying smaller struct to bigger one. It wou=
ld
> | work like that:
> | 1. set default values for in-kernel structure,
> | 2. copy min(msg_control, sizeof(struct dccp_packet_info)) bytes from
> | userspace structure to the kernel one.
> |
> | In that sense the code above is in fact wrong but the idea alone should
> | be ok. --
>
> There is a more serious problem here: apparently no one tried to compile
> the `qpolicy' subtree since the changes on Monday. It fails with the
> BUILD_BUG_ON.
>
> I tried yesterday evening and found that there is not even a possibility
> of adding a single field to struct dccp_skb_cb: with the addition of the
> inet{,6}_skb_parm, the struct has reached its maximum size of 48 bytes
> (try printk("%u", sizeof(struct dccp_skb_cb));).
>
> There is a solution to this, will post a revised patch shortly.
>
What you proposed in the patch should work ok for qpolicies for now. But=20
sooner or later the need to add a field to struct dccp_skb_cb will arise. S=
o=20
maybe we should think about it now...
Other possibility apart from what you proposed in the patch is creating str=
uct=20
dccp_skb_cb_ext, move to it some fields from struct dccp_skb_cb and in stru=
ct=20
add a pointer to this new struct dccp_skb_cb_ext. Ok, maybe it is not the=20
prettiest idea but in case somebody needs yet another additional field in=20
struct dccp_skb_cb_ext it would be nice to have an idea how to do it.

> With regard to your point above: I think there is a way of keeping the
> framework open without bending over backwards to ensure the binary
> compatibility.
>
While we are developing in the test tree compatibility is not important at =

all. But real world needs compatibility, especially if it's not that=20
expensive. Otherwise people will get weird behaviour without any messages=20
indicating what is wrong. And it's certainly not how code should be written=
.=20
It can't be that binary package of VLC (or any other streaming server) cann=
ot=20
use newer kernel version because we added a new field.

> My question for you in this regard: which policy can you think of whose
> priorities/preferences can not be mapped into an unsigned 32-bit
> integer? I think that such a number is sufficiently expressive enough
> to cater for a wide range of policies. It can be interpreted as
>  * symbolic value (enum)
>  * ascii string (similar to DCCP service code)
>  * millisecond timeout (with room for up to 7 weeks)
>  * microsecond timeout (with room for up to 1.19 hours)
>  * priority values (the large range 0..2^32-1 can be partitioned)
>  * ... ?
>
Putting any of those values in an integer is pretty straightforward. But wh=
en=20
you want to put both timeout and priority things get messy. Would it be=20
possible at least to use structure like that:
struct dccp_packet_info
{
	s8	priority;
	u16	timeout_mantissa:10;
	u16	timeout_exponent:6;
}
? That would still fit in 32-bit integer (so could be stored in=20
skb->priority), but would provide a much cleaner interface.
--=20
Regards,
Tomasz Grobelny
