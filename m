From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 24 Jun 2008 08:02:42 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806241002.42482.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 23 of June 2008, Gerrit Renker napisa=B3:
> | > We could still encode the parameters in the policy ID, by splitting t=
he
> | > bitmask, e.g. the low 24 bits to encode parameters, and the high 8 bi=
ts
> | > to encode the policies using the same combination of parameters.
> |
> | Yes, technically we could do it this way. Encoding accepted parameters =
in
> | policy ID would provide applications with means to check whether certain
> | parameters are supported. But should we mix two IMO distinct concepts
> | (policy behaviour and accepted parameters) in one bitfield? I'd rather
> | have them separated.
>
> Yes having them separate gives a clearer semantics. But it comes at a pri=
ce
> - to retrieve the parameters, we need an extra function or lookup table.
>
An additional bitfield in dccp_qpolicy_operations should do it when it come=
s=20
to storing that information. When it comes to retrieving see next point...

> Maybe there is an elegant solution which allows to encode the required
> parameters while keeping the semantics clear?
>
What about something like:
	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_ID, DCCPQ_POLICY_PRIO);
to choose policy (exactly as it is now) and a new function to ensure that t=
he=20
kernel understands parameters:
	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_PARAMS, DCCP_SCM_PRIORITY |=20
DCCP_SCM_TIMEOUT);

The second call would return an error if the kernel does not know anything =

about DCCP_SCM_TIMEOUT (or a choosen policy does not support it). This woul=
d=20
have the additional benefit (over similar getsockopt) that the kernel will =
be=20
able to optimize its behaviour knowning the set of parameters that will be =

used.

What do you think about such an interface?
--=20
Regards,
Tomasz Grobelny
