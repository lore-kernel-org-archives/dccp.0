From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 23 Mar 2008 18:25:07 +0000
Subject: Re: packet priorities
Message-Id: <200803231925.07836.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Thursday 20 of March 2008, Gerrit Renker napisa=B3:
> | > But I think there is a point in here to keep the init() function
> | > pointer: if you can think of a policy which depends on the queue
> | > length, this could be set via the init() function; and the init
> | > function would be called after all the setsockopt options (thereby ab=
le
> | > to override user defaults).
> |
> | Choosing way the packets are queued by a policy based on requested queue
> | length might be an interesting feature I haven't thought about. But note
> | that setsockopts for changing policy and changing queue length can be
> | called in any order. If we first change the policy (hence call init())
> | and then change queue length (which, as you propose, would not call any
> | policy specific function) then we end up with somewhat inconsistent
> | state.
>
> Good point, this needs order. I'd like to ask one question to clarify:
>  (1) Changing the policy during the connection: is there any real
>      benefit in doing this? If you want to allow changing the policy
>      on-the-fly, while the connection is going on, problems arise:
> (...)
I think you are right. Changing policy on the fly creates lots of problems =
and=20
gains us very little. Most of the problems can be solved by clearing packet=
=20
queue, but as you said: it gets messy.

> | > Same point - I can't see any purpose served by the get/setsockopt
> | > function pointers here. I had to sit down and think this one over. I
> | > think you want to find a way of passing policy-specific data to the
> | > policy struct, using either sysctls, specific get/setsockopt function
> | > pointers.
> |
> | Yes, I wanted to use both. sysctls for global default values and
> | set/setsockopt for individual per socket settings. And while sysctls are
> | not a must have I think that get/setsockopt would be a nice thing. One
> | could for example provide userspace applications with information on how
> | the policy is operating (average queue length, number of dropped/sent
> | packets per band, number of timed out packets, etc.).
>
> Agree now with the set/getsockopts, sorry it took me a bit longer to
> understand. But am still uneasy with the sysctls, since they will
> apply only to some specific policy.
>
Ok, I can remove the sysctls. The important question is: should we keep=20
pregister function pointer? To keep the code simple for now we should=20
probably remove it, right?

> | My point about tx_qlen is that it affects how a policy works and should
> | therefore be policy specific setting managed by the policy. For me it
> | logically belongs to a policy. The main weakness of this design is that
> | tx_qlen exists in all policies I can think of...
>
> I agree with both points and have looked back at the code: what I said
> was not exactly accurate and I think it contributed to some confusion
> regarding sysctls and socket options: currently the tx_qlen is a single
> sysctl for all connections/sockets, there is no per-socket information
> for tx_qlen (apart from the `qlen' field of the sk_write_queue).
>
> So yes, I think you are right - it needs to be part of the private data
> of the policy, even if it re-appears in all known policies.
>
Then what should be the sequence to set up socket?
1. create socket
2. setsockopt policy_id -> does not call any policy specific code
3. setsockopt tx_qlen -> calls policy specific setsockopt
4. connect() or listen() -> calls policy specific init()
Am I right?

> In this way, private data of struct queuing_policy can be anything
> instance-specific, and yet be accessed in a uniform manner.
>
I've noticed that pattern but after writing my code. I'll try to change my =

code to look similar.
--=20
Regards,
Tomasz Grobelny
