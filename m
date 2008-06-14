From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 14 Jun 2008 23:58:28 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806150158.28488.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Thursday 12 of June 2008, Gerrit Renker napisa=B3:
> | But if the application wants information about implemented parameters
> | there is currently no way to get it. It can try to send() packet and
> | check return value (which is quite a hack to be honest). It will work if
> | the parameter is not implemented at all. But what happens when you try =
to
> | set priority for a packet and use "simple" qpolicy? AFAIR nothing - you
> | get no information whatsoever that this parameter will not be used insi=
de
> | qpolicy.
> |
> | And that's why we need information about parameters in /proc or
> | /proc/sys.
>
> Sorry I can't see here why we need information about parameters. When
> introducing a new socket option there is a convention of how to use it.
>
> For sockopts, the type of the argument is listed for each option type.
>
You seem to assume that a given qpolicy is a fixed set of functionality at =
the=20
time of submission to the mainline kernel. In that case you are right, the =

application developer knows which parameters he can attach to a packet to b=
e=20
sent (and (s)he knows it at the time of development), so no parameter=20
detection is necessary.

But I view it a bit differently. I think we have to go back to the discussi=
on=20
about how to add the "timeout" parameter (or any other). Basically there ar=
e=20
two ways:
 1. add a new "timeout" qpolicy (as you proposed),
 2. extend an existing "prio" qpolicy adding DCCP_SCM_TIMEOUT parameter (as=
 I=20
propose). BTW, the "prio" name is a bit misleading, the qpolicy should=20
probably be named "advanced" or something like that.

In other words the basic question is: do we want to add new parameters to=20
existing qpolicies (then we need parameter discovery) or we don't want new =

parameters (then we don't need information about parameters available at=20
runtime).

Having defined the alternatives it's time to decide which is better. I, of =

course, claim that mine (which is adding new parameters to existing=20
qpolicies). That's simply because I think that providing both=20
DCCP_SCM_TIMEOUT and DCCP_SCM_PRIORITY parameters may be useful. And I don'=
t=20
see an obvoius way of achieving that goal with "new policy for new paramete=
r"=20
approach.

I hope this lengthy text is understandable. Either way, the question is=20
simple: what is your concept of adding DCCP_SCM_TIMEOUT parameter?

> | > If we agree on using unique strings to identify qpolicies then we can
> | > keep the runtime discovery much simpler. I think a manpage would be
> | > more helpful here, since the runtime discovery of parameters is not
> | > immediately obvious.
> |
> | Manpage of what? Documentation is certainly needed but before writing o=
ne
> | we need to have a basic implementation we agree upon.
> | --
>
> There is indeed a misunderstanding.
>
> We have already an implementation we agreed upon:
> http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcom=
mitd
>iff;h=87cf8b3ce96397f934775617ba24eb1ff404747a
>
Yes, but I would consider it not yet ready for application development. Why=
?=20
See subject of this mail and previous paragraphs.

> With a manpage I mean to document
Is there any "man dccp"?

>  * how the two currently available qpolicies ("simple" and "prio") are
> enabled; * which additional constraints they have (e.g. how they interpret
> tx_qlen); * information specific to a policy (e.g. that higher priority
> values in the "prio" policy mean a higher priority, comparable to
> SO_PRIORITY in socket(7)); * which ancillary data the policies require (t=
he
> procfs parameters) - simple: no ancillary parameters
>    - prio:   u32 priority value, passed as DCCP_SCM_PRIORITY via cmsg(3),
>              using a level of SOL_DCCP and a length of
> CMSG_LEN(sizeof(uint32_t)); * ... probably I have missed something here
>
Fine. But where exactly should it be described? Which file? I downloaded=20
latest man pages from [1] but dccp is not even mentioned there. Or should a=
=20
new man page be created (which would involve explaining what is dccp in the=
=20
first place)?

[1] http://www.kernel.org/pub/linux/docs/manpages/man-pages-2.80.tar.bz2

> With that kind of documentation, I think, we would not need runtime
> discovery of parameters.
I still don't agree, see previous paragraphs.
--=20
Regards,
Tomasz Grobelny
