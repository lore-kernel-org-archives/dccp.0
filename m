From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 08 Jun 2008 12:21:25 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806081421.25688.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 04 of June 2008, Gerrit Renker napisa=B3:
> | Now that I had a closer look at implementing this functionality I have a
> | few questions:
> | 1. Where should information about available qpolicies and their paramet=
rs
> | be exported? Would /proc/net/dccp/qpolicies/ be a good choice?
>
> For a sketch or a first implementation, procfs sounds like a good starting
> point.
>
> But since it is about dynamic runtime configuration, how about using sysfs
> or configfs instead? This is a brainstorming question, I think that sysfs
> is generally preferred. I don't know how well configfs has taken off, it =
is
> similar, but needs to be added in the configuration (under Pseudeo
> Filesystems, CONFIG_CONFIGFS_FS=3Dy|m) http://lwn.net/Articles/148973/
> and Documentation/filesystems/configs. But this could be done later as
> well.
>
procfs has some fine example of being used for this kind of information,=20
namely /proc/cpuinfo and /proc/meminfo
sysfs: from sysfs-rules.txt: "(...) the sysfs interface cannot provide a=20
stable interface (...)"
configfs is for configuring kernel from userspace. Which is quite opposite =
to =20
what we want.

> | 2. I guess we should have at least one file per qpolicy with parameters
> | listed inside. Like that:
> | /proc/.../qpolicies/simple: <empty>
> | /proc/.../qpolicies/prio: 1 (DCCP_SCM_PRIORITY) 2 (DCCP_SCM_TIMEOUT)
>
> Hm this is a "policy" question -- isn't the `timeout' policy a
> standalone variant?
>
It seems we have a bit different views on the subject. But that's to be=20
decided when somebody comes round to implementing timeout.

> | But we could also have qpolicy represented by directory and parameters =
by
> | files: /proc/.../qpolicies/simple/
> | /proc/.../qpolicies/prio/
> | /proc/.../qpolicies/prio/priority: <empty>
> | /proc/.../qpolicies/prio/timeout: <empty>
> | Which layout do you find better?
> | --
>
> I don't like the empty files. In the procfs for thinkpad Acpi
> configuration, for example, there is a line that says which commands are
> acceptable, similar for /sys/power/state. In that way, the (sysfs|procfs)
> file documents itself and tells the user what can be done with it. It wou=
ld
> be great if the qpolicies could do something similar.
>
Ok, I'll try to write a simple patch for that.
--=20
Regards,
Tomasz Grobelny
