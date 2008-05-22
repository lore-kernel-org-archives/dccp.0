From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 22 May 2008 00:35:41 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200805220235.41441.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 21 of May 2008, Gerrit Renker napisa=B3:
> Hi Tomasz,
>
> | Since packets with invalid cmsg parameters can be rejected by kernel
> | there is a need to allow applications to access information on available
> | policies and their respective cmsg parameters at runtime. This patch
> | simplifies maintaining compatibility between userspace applications and
> | DCCP code.
>
> The difference to querying supported CCIDs is that
>  * CCIDs are all defined per RFC documents, and that
Yes, but does that change anything?

>  * different combinations of CCIDs are possible due to the Kconfig option=
s.
>
Here we can have various kernel versions which is not much different. In bo=
th=20
cases we need runtime feature detection.

> As far as I understand your patch, querying here has a different role -
> ensuring compatibilities between kernel versions.
>
Yes.

> I think it might be too early for that:
>  * it takes quite a long while until patches propagate through to
>    mainline (more than half a year), so that there is the time to
>    come up with a single, well-tested interface;
But when it gets into mainline people should be able to write applications =

that will be forward and backward compatible (as far as possible) with=20
various kernel versions.

>  * at this stage it would be better to have documentation (man pages,
>    web pages, sample application code etc.) to allow people to use
>    the interface - few will want to discover the interface by grepping
>    through source code.
>
Sure it would be nice to have applications that use this interface. But in =
my=20
opinion the basic interface is not yet ready to be included in mainline=20
applications. It especially lacks features that will allow application=20
developers to maintain compatibility.

> DCCP is full of half-finished things.=20
That's why I'm trying to finish the qpolicy framework. Without providing=20
runtime information it will turn out that application developers will be=20
afraid to use new features just because the application won't be able to=20
check if given parameter is supported or not.

> I would much prefer to keep this=20
> as simple as at all possible, to have time/room to fix the missing parts
> (such as no ECN support) in DCCP.
>
I understand that there might be some missing features in DCCP that are mor=
e=20
important than yet another informational getsockopt. But these features are=
=20
IMO highly independent and can be developed in parallel.

> As a possible suggestion, I came up with a minimalistic variant of
> querying the interface - only 7 lines, including documentation.
>
> This is attached and it works by exploiting that
>  * policy IDs are just numbers;
>  * so that we could use the highest supported ID instead of an array;
I don't like the "highest supported ID" approach. But if you don't like arr=
ays=20
a simple "bool getsockopt" would do, we could just ask the kernel if it=20
supports given qpolicy. Like (in pseudocode):
bool supports_prio=3Dgetsockopt(sk,DCCP_SOCKOPT_QPOLICY_AVAILABLE,QPOLICY_P=
RIO);
Would that be ok?

>  * parameters are tied to the individual policy, so that a second
>    query (about which parameters are supported) is not necessary.
>
Can you guarantee that nobody ever will add a parameter? In fact even today=
 I=20
can think of two parameters that could be added: the previously discussed=20
timeout and my new concept - the identity or category parameter (which is a=
=20
subject for a separate thread).

BTW, the somewhat big code was meant to act as a framework for other featur=
es.=20
Like getting information about percent of dropped packets in prio qpolicy=20
queue.
--=20
Regards,
Tomasz Grobelny
