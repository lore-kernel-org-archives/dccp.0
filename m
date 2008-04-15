From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 15 Apr 2008 18:01:58 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804152001.58528.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 15 of April 2008, Gerrit Renker napisa=B3:
> | | What happens if application is compiled with dccp_packet_info
> | | containing only one field (priority) and kernel containing two fields
> | | (for example priority and later added expiry time)? Wouldn't that
> | | implementation make extensions to dccp_packet_info impossible?
> |
> | Had not looked at it from this point of view. So you are suggesting
> |
> | 	if (msg->msg_control !=3D NULL && msg->msg_controllen >=3D sizeof(*dcp=
))
> | 		dcp =3D (struct dccp_packet_info *)msg->msg_control;
> |
> | instead? Agreed, point #1 to change in the patch.
>
> No, the above is nonsense. If the application uses an earlier version of
> the API, then it needs to be recompiled, there is no way it could pretend
> to have an adequate size.
>
That would effectively stop development of any policy. And it's not about=20
pretending the structure has different size, it's just about using only the=
=20
data that is provided by the application (even though it may be incomplete).

> So my take is that still the '=3D' is correct. But maybe this is a known
> problem?
>
I can't see a problem with copying smaller struct to bigger one. It would w=
ork=20
like that:
1. set default values for in-kernel structure,
2. copy min(msg_control, sizeof(struct dccp_packet_info)) bytes from usersp=
ace=20
structure to the kernel one.

In that sense the code above is in fact wrong but the idea alone should be =
ok.
--=20
Regards,
Tomasz Grobelny
