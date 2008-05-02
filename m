From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 02 May 2008 20:39:58 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200805022239.58699.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 30 of April 2008, Gerrit Renker napisa=B3:
> | c) allow qpolicy to use each cmsg header as different parameter. So that
> (...)
> I think (c) is best, here is what I'd support.
> (...)
Seems we are getting closer in our views, see the just sent patch.

> Ok, but this is a separate question and it is about a yet non-existing
> policy.
>
Hopefully someone, someday will implement it. So it is good to have a basic=
=20
idea how it might work.

> So far there is a "priority" policy, for which I think we agree that 32
> bits are enough.
>
For storing just priority - yes. I'd even say that it is too much...

> And both associated parameters can be parsed differently, in particular
> there is no requirement to restrict DCCP_SCM_TIMEOUT to use 32 bits - it
> could even pass a struct timeval or struct timespec.
>
Yes, that's nice.

> Then there is a yet non-existing "timeout" policy, which has no associated
> field yet. If we can assume that e.g. the skb->tstamp field can be used
> to store timeouts, then there are separate fields associated with separate
> policies.
>
> Thirdly, there is the aggregate policy "priority+timeout", which can
> then use both skb->priority and skb->tstamp.
>
> I.e. to answer the question, I think it is best to implement "timeout"
> first, solve the problems it brings up; when that is done,
> "priority+timeout" will be easy to do - it could be constructed just out =
of
> the existing functions defined for "priority" and "timeout".
>
> In that manner, other policies can be modularly constructed - for instance
> by combining "timeout" with a different form of the "priority" policy.
>
I'm not entirely sure if such modular constructions would be possible. I=20
prefer to think of "timeout policy" and "prio policy" as a special cases=20
of "timeout+prio policy" with respectively DCCP_SCM_PRIORITY and=20
DCCP_SCM_TIMEOUT not supplied (and thus set to their default values: 0 and =

INFINITY).
--=20
Regards,
Tomasz Grobelny
