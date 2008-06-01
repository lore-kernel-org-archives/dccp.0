From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 01 Jun 2008 17:48:39 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806011948.39770.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 26 of May 2008, napisa=B3e=B6:
> Dnia Monday 26 of May 2008, Gerrit Renker napisa=B3:
> > | As for information we can get from kernel wrt dccp we have at least:
> > | 1. fixed information that depends only on kernel version. For example
> > | list of ccids, list of available qpolicies, list of parameters for
> > | given qpolicy, etc. These are system wide and don't need reference to
> > | socket. These could even be exposed by read-only entries in /sys or
> > | /proc.
> >
> > That is a good point - I think Arnaldo had a similar idea once for
> > implenting system-wide policies regarding which CCIDs are supported.
> > Something like net.ipv4.tcp_available_congestion_control.
>
> Ok, we may go this way. I'll try to write a patch in a few days (quite bu=
sy
> now).
>
Now that I had a closer look at implementing this functionality I have a fe=
w=20
questions:
1. Where should information about available qpolicies and their parametrs b=
e=20
exported? Would /proc/net/dccp/qpolicies/ be a good choice?
2. I guess we should have at least one file per qpolicy with parameters lis=
ted=20
inside. Like that:
/proc/.../qpolicies/simple: <empty>
/proc/.../qpolicies/prio: 1 (DCCP_SCM_PRIORITY) 2 (DCCP_SCM_TIMEOUT)
But we could also have qpolicy represented by directory and parameters by=20
files:
/proc/.../qpolicies/simple/
/proc/.../qpolicies/prio/
/proc/.../qpolicies/prio/priority: <empty>
/proc/.../qpolicies/prio/timeout: <empty>
Which layout do you find better?
--=20
Regards,
Tomasz Grobelny
