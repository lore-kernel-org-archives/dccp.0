From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 22 May 2008 17:48:18 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200805221948.18305.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Thursday 22 of May 2008, Gerrit Renker napisa=B3:
> | But when it gets into mainline people should be able to write
> | applications that will be forward and backward compatible (as far as
> | possible) with various kernel versions.
>
> The main answer to that is below, but compare for instance with TCP -
> few socket options need runtime discovery. The type of their parameters
> and their option values are all described in a manpage. On the other
> hand, I like your approach of trying to come up with a novel solution.
>
TCP was designed before the era of having everything pluggable. DCCP on the=
=20
other hand is prepared for adding new CCIDs. Logically then, it should be=20
extensible in other areas too.

> | > As a possible suggestion, I came up with a minimalistic variant of
> | > querying the interface - only 7 lines, including documentation.
> | >
> | > This is attached and it works by exploiting that
> | >  * policy IDs are just numbers;
> | >  * so that we could use the highest supported ID instead of an array;
> |
> | I don't like the "highest supported ID" approach. But if you don't like
> | arrays a simple "bool getsockopt" would do, we could just ask the kernel
> | if it supports given qpolicy. Like (in pseudocode):
> | bool
> | supports_prio=3Dgetsockopt(sk,DCCP_SOCKOPT_QPOLICY_AVAILABLE,QPOLICY_PR=
IO);
> | Would that be ok?
>
> What I sent is just a sketch, nothing set in stone. I am happy to take
> my patch out of the repository if there are better solutions.
>
The question is: would you consider such a solution better?=20

> | >  * parameters are tied to the individual policy, so that a second
> | >    query (about which parameters are supported) is not necessary.
> |
> | Can you guarantee that nobody ever will add a parameter? In fact even
> | today I can think of two parameters that could be added: the previously
> | discussed timeout and my new concept - the identity or category paramet=
er
> | (which is a subject for a separate thread).
>
> During the design phase it is almost certain to change several times.
>
> When the design phase is over, it will have some parts that will not
> likely change.
>
> Hence I am trying to figure out - how much change is due to re-designing
> things and how much change is de facto required for a useful dynamic
> interface?
>
IMO we could divide the interface into two parts:
 - operations - they are likely to stabilize before pushing the code to=20
mainline,
 - parameters (all kinds of numbers like DCCP_SCM_xxx, qpolicy ids, etc.) -=
=20
there should always be a room for new ones (and maybe even deleting old=20
ones). And one should be able to verify which numbers are valid - that's wh=
y=20
we need operations for this purpose that are available from the very=20
beginning.

> | BTW, the somewhat big code was meant to act as a framework for other
> | features. Like getting information about percent of dropped packets in
> | prio qpolicy queue.
> | --
>
> Ah - didn't understand what the qpolicy-specific getsockopt hooks were fo=
r.
>
> I think there is a way of doing this, but it requires a bit more work.
> This would be to use netlink sockets to communicate/request/poll
> information.
>
> The two alternatives I am aware of are
>
>  * kernel/userspace connector
>    [ Documentation/connector/connector.txt ]
>  * generic netlink interface
>    http://www.linux-foundation.org/en/Net:Generic_Netlink_HOWTO
>
As far as I understand netlink is a kind of intermodule communication=20
mechanism (where module may be either in-kernel or userspace application).

> If done well, the interface could be very useful for several other
> things in DCCP:
>  * querying qpolicy interface (with regard to this email thread)
>  * querying the CCIDs (available, set preference list)
>  * getting much-needed runtime statistics into user-space
>    - this is a feature missing in UDP (and partly also TCP)
>    - so far only via CCID-3 getsockopt (tx_info/rx_info)
>    - there is research which says it would be nice to have the
>      current RTT, loss statistics etc in user-space
>  * thus calling for a generic solution.
>
> What do you think about this alternative?
>
I have nothing against creating generic interface for obtaining information=
=20
about various aspects of dccp. But I can't see how netlink can help us here=
.=20
From the documents I've read I understand that generic netlink requires you=
=20
to create a special kind of socket type and then you can send or receive=20
information through it. But it seems to be something separate from dccp=20
sockets.

As for information we can get from kernel wrt dccp we have at least:
1. fixed information that depends only on kernel version. For example list =
of=20
ccids, list of available qpolicies, list of parameters for given qpolicy,=20
etc. These are system wide and don't need reference to socket. These could =

even be exposed by read-only entries in /sys or /proc.
2. typical socket options. Among others: currently used rx/tx ccid, current=
ly=20
used qpolicy, queue and buffer sizes, etc. For these we need reference to=20
socket and get/setsockopts are the natural choice. And I guess no changes=20
should happen here.
3. statistics. These are not options in the sense that you cannot set them.=
=20
You also cannot expect that two consecutive reads will return the same valu=
e.=20
They depend on certain asynchronous events in various parts of dccp code. T=
he=20
first question is: should we pass those raw events to applications (such=20
as "prio qpolicy: packet dropped") or aggregate data ("in the last 100=20
packets 17 were dropped before sending")? For this kind of information we=20
need reference to socket (struct sock *). And I can't see how we could obta=
in=20
it from functions not mentioned in struct proto.

I suggest that we discuss points 1 and 3 separately because it may turn tha=
t=20
different mechanisms will be applicable. getsockopt is possible in both whi=
ch=20
doesn't mean that it is the best solution.
--=20
Regards,
Tomasz Grobelny
