From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 08 Jul 2008 19:47:27 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200807082147.27612.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 08 of July 2008, Gerrit Renker napisa=B3:
> Thank you for those scenarios -- the problem is now better to understand.
>
> | I would like to know how applications are supposed to use DCCP in 4
> | scenarios:
>
> (1) ... (3) can be handled without too many ambiguities; (4) seems to be
> the key point.
>
Yes, but difference between 1 and 2 also needs some consideration.

> | 1. The application wants to use the old behaviour (that is simple policy
> | with no parameters).
>
> By setting the ID for the `simple' policy (which does not use parameters)
> to 0.
>
Which is the default, by the way.

> | 2. The application wants to use prio policy but needs no parameters.
>
> That should not be a problem if we only check the supplied parameters.
>
> The prio policy (any policy for that matter) needs a way of interpreting
> the absence of parameters meaningfully.
>
Currently prio policy should do fine. The result would be the same as if al=
l=20
packets were supplied with the same parameter. In effect 'random' packets a=
re=20
dropped.

> | 3. The application wants to attach priority information to each packet.
>
> This would be the default/expected case.
>
Yes.

> | 4. The application wants to attach priority and timeout information to
> | each packet. If kernel cannot process timeout then fall back to priority
> | information only.
>
> I can think of at least two ways of tackling this -- maybe there are more:
>
>   (a) Separate policies for "prio" and "prio with timeout"
>       ---------------------------------------------------
>       Would be resolved when trying to set "prio with timeout" policy - t=
he
>       kernel would either accept (and understand) it or return an error.
>
So we would have "simple", "prio" and "prio with timeout" policies. The=20
questions are:
1. Should we have "timeout" policy as well?
2. Should we have "prio without priority"* policy as well?

* On this example we clearly see that prio is not the best name possible.=20
Maybe something like "realtime policy" would be better? Because the key=20
difference to "simple" policy is the fact that send never waits (ie. the=20
queue seems to be never full). Maybe there exists an even better name=20
than "realtime". What do you think of changing the name?

>   (b) Use of optional parameters
>       --------------------------
>       If I understand you correctly, this is actually the way you would
>       design the use of parameters, and my understanding of it is to
>       that there are a few basic (well-defined) policies which could be
>       combined with a number of optional additional parameters -- is that
>       your idea?=20
Yes. The point is: as long as you don't change the basic behaviour there is=
 no=20
need to change policy name/number. Timeout parameter would be entirely=20
optional with default value of infinity. If you were to add a required=20
parameter new policy would probably have to be created.

>       If this is the case then we need to step back and sort=20
>       out the base policies plus set of optional parameters, and find a
>       way of dealing with each combination. At first sight, this seems
>       more difficult and complicated than (a).
>
For me it's not. Note that for each main policy you only have to think abou=
t=20
two things:
1. How should it behave if all parameters are supplied.
2. If not all parameters are supplied what should be their default values. =
For=20
priority it could be 0, for timeout it could be infinity. If you cannot thi=
nk=20
of a sensible default value for a parameter it is a sign that new policy=20
should be created.

In effect you don't have to think about each combination of parameters=20
separately.

> Not directly related to above questions, but rather as inspiration I
> attach the sketch which I did for the definition of qpolicies. The idea
> is to use a separate enum for each combination of parameters. The first
> entry is initialised using the parameter bitmask, subsequent entries
> have subsequent numbers.
>=20
1. I would summarise difference in our ideas as follows:
My approach: we have an algorithm (policy) and let's think what can affect =
the=20
behaviour of this algorithm =3D> algorithm is first, set of parameters is=20
second.
Your approach: we have a set of parameters and let's think what algorithm=20
(policy) can be used to manage them =3D> set of parameters is first, algori=
thm=20
is second.

2. By choosing policy DCCPQ_POLICY_TIMED_REVERSE_PRIO you basically give th=
e=20
kernel two pieces of information:
  a) what set of parameters will be used (QPOLICY_INITIALISER(QP_PARAM_PRIO|
QP_PARAM_TIMEO)),
  b) how packets will be managed in a queue=20
(DCCPQ_POLICY_TIMED_REVERSE_PRIO-QPOLICY_INITIALISER(QP_PARAM_PRIO|
QP_PARAM_TIMEO)).

Do we agree in these points?
--=20
Regards,
Tomasz Grobelny
