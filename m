From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 11 May 2008 00:31:18 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <200805110231.18540.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080502202242.74967BC4D@poczta.oswiecenia.net>
In-Reply-To: <20080502202242.74967BC4D@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Friday 09 of May 2008, Gerrit Renker napisa=B3:
> | > | > | -		default:
> | > | > | -			return -EINVAL;
>
> <...>
>
> | > By taking them out, you are robbing yourself of the possibility to
> | > distinguish between truly invalid arguments ("EINVALs") and
> | > incompatibilities.
> |
> | But do we need such distinction? If kernel cannot understand part of cm=
sg
> | data we should just ignore this part. The application will work, maybe
> | slightly less effective than the author intended but it's better than
> | returning error and making it completely useless. This could be called
> | best-effort approach. However, we could return error on unknown or
> | invalid data provided applications can detect which parameters are
> | supported prior to packet submission.
> |
> | To summarise I see two options here:
> | 1. Provide a way for applications to ask at runtime which DCCP_SCM_xxx
> | options are supported by running kernel. And always return EINVAL on
> | unsupported data.
> | 2. Allow ignoring unknown data, it doesn't have to be the default. This
> | could take a form of setsockopt(IGNORE_UNKNOWN_CMSG_DATA) call.
> |
> | Both ways the default would be as you propose but applications would be
> | able to work around older kernel version. What do you think about it?
>
> With that explanation I understand clearer where you would like to go. I
> don't like (2) since it makes the API more complex (instead of thinking
> what to accept, the API then also needs to know what to ignore).
>
It just ignores everything that it cannot understand, I don't see anything =

complex about that. At least when it comes to implemetation. But I understa=
nd=20
that applications should always provide correct parameters. So let's agree =

that (1) is to be implemented in future.

> So I'd prefer (1). Like the struct qpolicy_args, this could be something
> done later, when there are more qpolicies.
>
> A similar mechanism was used for the CCIDs with
> ccid_getsockopt_available_ccids(), which would be one possibility -
> returning an array of possible policy IDs.
>
List of possible qpolicies is one thing, the other is a list of parameters =

supported by choosen qpolicy.

> I don't know what your extension plans are, my suggestion is to wrap up
> the patches in the qpolicy subtree, cast them as one patch within the
> test tree and continue any additions/further work based on that.
>
Agreed, the only thing that may need correction now is this line:
	skb->priority =3D *(__u32 *)CMSG_DATA(cmsg);
But I really don't know how it should look like, and I have neither knowled=
ge=20
nor machines to test on other architectures. Other than that we could=20
consider the patch ready.

As for my extension plans, I can see a few things that could be improved:
 - adding timeout parameter,
 - providing information about available qpolicies and parameters to=20
userspace,
 - providing statistical information about qpolicy to userspace application=
s.
(That doesn't necessarily mean I wish to write patches for all these=20
features.)
--=20
Regards,
Tomasz Grobelny
