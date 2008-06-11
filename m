From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 11 Jun 2008 17:43:42 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806111943.42390.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 10 of June 2008, Gerrit Renker napisa=B3:
> | > But since it is about dynamic runtime configuration, how about using
> | > sysfs or configfs instead? This is a brainstorming question, I think
> | > that sysfs is generally preferred. I don't know how well configfs has
> | > taken off, it is similar, but needs to be added in the configuration
> | > (under Pseudeo Filesystems, CONFIG_CONFIGFS_FS=3Dy|m)
> | > http://lwn.net/Articles/148973/ and Documentation/filesystems/configs.
> | > But this could be done later as well.
> |
> | procfs has some fine example of being used for this kind of information,
> | namely /proc/cpuinfo and /proc/meminfo
> |
> | sysfs: from sysfs-rules.txt: "(...) the sysfs interface cannot provide a
> | stable interface (...)"
>
> Yes that is a key point and I think we are talking about the same point
> here.
>
> I had mentioned sysfs/procfs as alternatives not because they are the best
> possible match, but since it shows that similar problems (and likely
> solutions) exist also in other areas.
>
That's ok, I just mention what I know about them so that we can have comple=
te=20
argumentation for/against given solution.

> But there are also areas where the rate of change is relatively low or
> even absent: Documentation/ABI/README for instance mentions 4 different
> levels of stability (stable/testing/obsolete/removed), the most entries
> are under `testing'.
>
This one should probably be marked as testing too. And probably be moved to=
=20
stable with time (when it proves useful for applications).

> | configfs is for configuring kernel from userspace. Which is quite
> | opposite to what we want.
>
> Ok I think I understand now where you are heading - but then we can go a
> much simpler route: why not implement a sysctl (which is also mirrored in
> /proc/sys) that contains all available/implemented qpolicies as a
> space-separated string, such as
>
> 	cat /proc/sys/net/ipv4/tcp_available_congestion_control ?
>
Could be /proc/sys. I just had an impression that sysctls are for setting=20
certain variables used in kernel. But as far as I understand it the=20
difference is highly subjective and I'm ok with both /proc and /proc/sys.=20
Would be nice to have more opinions (Arnaldo? others?) whether we should=20
favour one over other.

> And I think that it is unnecessarily complex to add the available
> parameters belonging to each qpolicy as well.
>
I think it is critical. If the application just wants to know which qpolici=
es=20
are available it can try to set it with setsockopt(). If it gets an error=20
given qpolicy is unavailable. As simple as that. No need for additional=20
interface.
But if the application wants information about implemented parameters there=
 is=20
currently no way to get it. It can try to send() packet and check return=20
value (which is quite a hack to be honest). It will work if the parameter i=
s=20
not implemented at all. But what happens when you try to set priority for a=
=20
packet and use "simple" qpolicy? AFAIR nothing - you get no information=20
whatsoever that this parameter will not be used inside qpolicy.

And that's why we need information about parameters in /proc or /proc/sys.

> If we agree on using unique strings to identify qpolicies then we can
> keep the runtime discovery much simpler. I think a manpage would be more
> helpful here, since the runtime discovery of parameters is not
> immediately obvious.
>
Manpage of what? Documentation is certainly needed but before writing one w=
e=20
need to have a basic implementation we agree upon.
--=20
Regards,
Tomasz Grobelny
