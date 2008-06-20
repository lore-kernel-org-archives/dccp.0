From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 20 Jun 2008 21:03:37 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806202303.37924.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Thursday 19 of June 2008, Gerrit Renker napisa=B3:
> But such a bottom-up approach would not necessarily make sense, since
> likely the policy will do a bit more work than just reacting to the
> parameters it uses, which leads to the next point.
>
Agreed.

> | Could be nice, but what happens if we have two policies with the same s=
et
> | of supported parameters? How do we differentiate them? In the above: how
> | do we diffrentiate between simple policy (which doesn't have any
> | parameters ever) and prio policy with no parameters (just because we
> | don't need to provide any for one particular case)?
>
> We could still encode the parameters in the policy ID, by splitting the
> bitmask, e.g. the low 24 bits to encode parameters, and the high 8 bits
> to encode the policies using the same combination of parameters.
>
Yes, technically we could do it this way. Encoding accepted parameters in=20
policy ID would provide applications with means to check whether certain=20
parameters are supported. But should we mix two IMO distinct concepts (poli=
cy=20
behaviour and accepted parameters) in one bitfield? I'd rather have them=20
separated.

Keeping policy IDs as they are and using a bitfield for just parameters cou=
ld=20
be a nice idea. It would certainly  simplify checking which parameters are =

supported - just a simple & and =3D would suffice.
--=20
Regards,
Tomasz Grobelny
