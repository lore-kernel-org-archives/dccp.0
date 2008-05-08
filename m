From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 08 May 2008 19:00:16 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <200805082100.16844.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080502202242.74967BC4D@poczta.oswiecenia.net>
In-Reply-To: <20080502202242.74967BC4D@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 06 of May 2008, Gerrit Renker napisa=B3:
> | > | -		default:
> | > | -			return -EINVAL;
> | >
> | > It should thrown an (EINVAL) error if the user supplied a wrong
> | > parameter - this function only checks for socket level SOL_DCCP and so
> | > if a wrong SCM_xxx is passed, it is an error.
> |
> | I deleted those two lines on purpose. If the kernel cannot understand
> | given DCCP_SCM_xxx then the application may have been written for newer
> | kernel. For example if application will specify DCCP_SCM_TIMEOUT and
> | kernel does not understand it the application can still run without
> | problems. It just won't be that effective.
> |
> | Maybe there are cases when all DCCP_SCM_xxx must be understood by kerne=
l.
> | For such cases we could have something like
> | setsockopt(MUST_UNDERSTAND_CMSG), would that be ok?
>
> In the online version of your patch (subtree `qpolicy' of the test tree)
> I have added them back in for now.
>
> By taking them out, you are robbing yourself of the possibility to
> distinguish between truly invalid arguments ("EINVALs") and
> incompatibilities.
>
But do we need such distinction? If kernel cannot understand part of cmsg d=
ata=20
we should just ignore this part. The application will work, maybe slightly =

less effective than the author intended but it's better than returning erro=
r=20
and making it completely useless. This could be called best-effort approach=
.=20
However, we could return error on unknown or invalid data provided=20
applications can detect which parameters are supported prior to packet=20
submission.

To summarise I see two options here:
1. Provide a way for applications to ask at runtime which DCCP_SCM_xxx opti=
ons=20
are supported by running kernel. And always return EINVAL on unsupported=20
data.
2. Allow ignoring unknown data, it doesn't have to be the default. This cou=
ld=20
take a form of setsockopt(IGNORE_UNKNOWN_CMSG_DATA) call.

Both ways the default would be as you propose but applications would be abl=
e=20
to work around older kernel version. What do you think about it?

> If it is really for an older kernel version, one can use something like
> the statement in net/dccp/proto.c
>
>   DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
>
The warning could be useful for application developers. I'm not sure if it =

makes sense to "display" it to users. But that's a minor issue.

> The main point of the perhaps a bit prolonged discussion is to avoid too
> many deprecated warnings, i.e. I'd prefer that the API does not change
> too often.
>
> On the other hand, making these changes is exactly what the test tree is
> for - so that change/revert cycles and deprecated-API warnings  need not =
be
> done later in mainline.
>
Sure it's better to minimize the amount of API changes in mainline. But I=20
prefer to prepare for changes rather than avoid them.

> | > With regard to the typecast, I found that such typecasts sometimes le=
ad
> | > to alignment errors, i.e. would require to use get_unaligned() (compa=
re
> | > e.g.	ccid3_hc_tx_parse_options() where this happened before using
> | > get_unaligned()).
> |
> | The CMSG_DATA() macro seems to take care of alignment, doesn't it?
>
> Not sure about this: the question is how memory is accessed in the typeca=
st
>
> 	skb->priority =3D *(__u32 *)CMSG_DATA(cmsg);
>
> and how is this access aligned? Doing a similar typecast for DCCP
> options (Timestamp, Timestamp Echo, Elapsed Time, CCID-3's Loss Event
> and Receive Rate) caused an alignment exception on Sparc64, since
> (half)word accesses need to be aligned on 2/4 byte boundaries.
>
> I tested the above and it actually worked. Since I can't say whether this
> was by accident or not, so it does seem safer to use get_unaligned().
>
I'm no expert on data alignment so I have to trust you here. Change as you =

think is correct.

> | I'm not sure if it's not a bit over-designed approach. But apart from
> | that I have nothing against it.
> |
> | One question: what should xxx_push() do with this additional argument?
> | Store it as whole (note that we don't have room in skb->cb) or rewrite
> | individual fields of dccp_qpolicy_args to fields of skb (like:
> | skb->priority =3D qp_args->priority;
> | )?
>
> That is the point I missed: it is not necessary to equip all xxx_push()
> routines with an extra argument, this can be done by the
> dccp_qpolicy_push() routine.
>
Could be, in fact I thought about moving code from dccp_msghdr_parse() to=20
dccp_qpolicy_push(). But on the other hand cmsg data doesn't have to be onl=
y=20
about qpolicies. I mean in theory because currently I cannot show a usecase=
=20
for non-qpolicy specific cmsg data. For me the code could either be as it i=
s=20
or could be moved to dccp_qpolicy_push(). Both options seem to be ok.

> The error in the above was to assume that qpolicy_args makes it no
> longer necessary to use skb fields, which is not true.
>
Right, it's not :-(

> I (...) am questioning whether this is not really over-designed.
>=20
I wonder if you could rephrase this sentence possibly using a bit simpler=20
English.
--=20
Regards,
Tomasz Grobelny
