From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 12 May 2008 08:24:40 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <200805121024.41245.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080502202242.74967BC4D@poczta.oswiecenia.net>
In-Reply-To: <20080502202242.74967BC4D@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 12 of May 2008, Gerrit Renker napisa=B3:
> | As for my extension plans, I can see a few things that could be improve=
d:
> |  - adding timeout parameter,
> |  - providing information about available qpolicies and parameters to
> | userspace,
> |  - providing statistical information about qpolicy to userspace
> | applications. (That doesn't necessarily mean I wish to write patches for
> | all these features.)
> | --
>
> Once the patch is in the test tree, we can keep the qpolicy subtree for
> further development/testing. Regarding statistics, there is a MIB in the
> code already (dccp_statistics), but when compiled as a module the
> statistics do not show up under /proc/net/snmp or /proc/net/snmp6 -
> maybe it works when compiling all of DCCP into the kernel.
>
By statistics I mean per socket information so that a given application can=
=20
get information about percentage of sent packets. For example if it gets=20
below 75% the application could switch audio/video codec to another having =

lower bitrate. But that is to be discussed when a patch appears.
--=20
Regards,
Tomasz Grobelny
