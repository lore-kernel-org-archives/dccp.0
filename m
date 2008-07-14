From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 14 Jul 2008 20:57:52 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200807142257.53046.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 14 of July 2008, Gerrit Renker napisa=B3:
> | > I can think of at least two ways of tackling this -- maybe there are
> | > more:
> | >
> | >   (a) Separate policies for "prio" and "prio with timeout"
> | >       ---------------------------------------------------
> | >       Would be resolved when trying to set "prio with timeout" policy=
 -
> | > the kernel would either accept (and understand) it or return an error.
> |
> | So we would have "simple", "prio" and "prio with timeout" policies. The
> | questions are:
> | 1. Should we have "timeout" policy as well?
> | 2. Should we have "prio without priority"* policy as well?
> |
> | * On this example we clearly see that prio is not the best name possibl=
e.
> | Maybe something like "realtime policy" would be better? Because the key
> | difference to "simple" policy is the fact that send never waits (ie. the
> | queue seems to be never full). Maybe there exists an even better name
> | than "realtime". What do you think of changing the name?
>
> I am much in support of (1) since this will be the default for many
> applications which are based on a best-before time value (RTP-based
> applications, video streaming for instance).
>
The question is not whether such a behaviour should be available to=20
applications. We both agree that it should. The question is: should it be a=
=20
separate policy? This is question about name, not about functionality.

> With regard to defining "salami baguette without salami", it would be best
> to write short, one-sentence descriptions of the behaviour of each policy.
> This makes it easier to later add documentation (manpage) and also to find
> an appropriate name. I had to look up "prio":
>
> DCCP_SOCKOPT_QPOLICY_TXQLEN sets [...]
> the "prio" policy enforces a fixed queue length by dropping the
> lowest-priority packet first.
>
> =3D> So call it something like "drop_lowest_prio_first"?
>
But then we still have "prio" in the name. So we will=20
have "drop_lowest_prio_first" without "priority". Not at all better.
Maybe just "drop", "drop_worst" (which I don't like since it has two=20
words), "realtime" or "rt"?

> | >       If this is the case then we need to step back and sort
> | >       out the base policies plus set of optional parameters, and find=
 a
> | >       way of dealing with each combination. At first sight, this seems
> | >       more difficult and complicated than (a).
> |
> | For me it's not. Note that for each main policy you only have to think
> | about two things:
> | 1. How should it behave if all parameters are supplied.
> | 2. If not all parameters are supplied what should be their default
> | values. For priority it could be 0, for timeout it could be infinity. If
> | you cannot think of a sensible default value for a parameter it is a si=
gn
> | that new policy should be created.
> |
> | In effect you don't have to think about each combination of parameters
> | separately.
>
> I am not sure I understand this. When it is used in a computer, the
> parameters and the algorithm need to be well-defined.
>
But we only need to define only one, maximum set of parameters and not all =

permutations of these parameters. This simplifies things. At the very least=
=20
it reduces number of needed enum values.

When you convert a string value to integer it is pretty obvious that this=20
string usually contains base 10 number. But you can still define other radi=
x=20
by specifying additional parameter. By using default parameter you don't ha=
ve=20
to implement atoi2(), atoi8(), atoi10(), atoi16(), atoi17(), ... functions.=
=20
Implementing just one, most complex case is enough.

Here we have the same situation: just one policy with a given behaviour is =

enough ("realtime"). If an application wants to provide priority - fine, ad=
d=20
timeout - fine, add fooparam - fine, but it doesn't affect the basic=20
algirithm.

> | Do we agree in these points?
> | --
>
> Yes we do - we are just using different names for the same things.
>=20
Nice. So now we have to decide which names should we use in code ;-)

BTW, I'm wondering whether it would be viable to move all this qpolicy stuf=
f=20
to userspace library. Of course it is not possible with current kernel, but=
=20
the longer we continue this discussion the more I am convinced that most of=
=20
my code should be outside kernel... There are two practical considerations,=
=20
though. First, it may be performance (I made no tests so I have no idea how=
=20
big the impact might be). Second, I need to have working code for my master=
's=20
thesis so I will not make any abrupt changes to my concept before October.
--=20
Regards,
Tomasz Grobelny
