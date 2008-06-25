From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 25 Jun 2008 20:15:19 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806252215.19851.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 25 of June 2008, Gerrit Renker napisa=B3:
> | > Yes having them separate gives a clearer semantics. But it comes at a
> | > price - to retrieve the parameters, we need an extra function or look=
up
> | > table.
> |
> | An additional bitfield in dccp_qpolicy_operations should do it when it
> | comes to storing that information. When it comes to retrieving see next
> | point...
> |
> | > Maybe there is an elegant solution which allows to encode the required
> | > parameters while keeping the semantics clear?
> |
> | What about something like:
> | 	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_ID, DCCPQ_POLICY_PRIO);
> | to choose policy (exactly as it is now) and a new function to ensure th=
at
> | the kernel understands parameters:
> | 	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_PARAMS, DCCP_SCM_PRIORITY |
> | DCCP_SCM_TIMEOUT);
> |
> | The second call would return an error if the kernel does not know
> | anything about DCCP_SCM_TIMEOUT (or a choosen policy does not support
> | it). This would have the additional benefit (over similar getsockopt)
> | that the kernel will be able to optimize its behaviour knowning the set
> | of parameters that will be used.
> |
> | What do you think about such an interface?
> | --
>
> In both solutions there is a need to maintain an integrity constraint
> between the qpolicy ID and the set of parameters that the qpolicy uses.
>
It is always the case, either explicit (as I propose) or implicit (when it =

would be a part of policy id).

> With the bitmask approach this constraint is expressed only once, when
> the policy is defined in the source file.
>
In what I propose it would also be defined once. Instead of:
	[DCCPQ_POLICY_PRIO] =3D {
		.push	=3D qpolicy_simple_push,
		.full	=3D qpolicy_prio_full,
		.top	=3D qpolicy_prio_best_skb,
	},
we would simply have:
	[DCCPQ_POLICY_PRIO] =3D {
		.push	=3D qpolicy_simple_push,
		.full	=3D qpolicy_prio_full,
		.top	=3D qpolicy_prio_best_skb,
		.params =3D DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT,
	},
Doesn't seem complicated, does it?

> With the socket approach, the constraint needs to be expressed each time
> the policy is used.
>
Yes. Two points:
1. The other option is /proc I guess... would that be better? I think not=20
(even though I had other optinion on this subject earlier).
2. I think that it is actually good to enforce on application developers th=
e=20
need to declare which parameters they want to use. This way they almost=20
cannot do it wrong.

> I don't know your reservations against the bitmask approach (other than t=
he
> semantics), but I find having to define the parameters each time the
> qpolicy is used cumbersome, and it can also be a source of errors.
>
The bitmask approach is ok but I view combining parameters with policy id=20
counterintuitive.

To make things clear: we both agree that the application should be able to =
get=20
information if the parameters it wants to use are supported by the kernel=20
it's running on, right?

The place where we differ is that you would prefer to have:
setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_POLICY_PRIO|(DCCP_SCM_PRIORITY<<8)=
);

and I would like to have:
setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_POLICY_PRIO);
setsockopt(sockfd, DCCP_POLICY_PARAMS, DCCP_SCM_PRIORITY);

Is that right?
--=20
Regards,
Tomasz Grobelny
