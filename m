From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 05 Jul 2008 16:42:04 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200807051842.05007.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Thursday 03 of July 2008, Gerrit Renker napisa=B3:
> We were at this point already and agreed not to change parameter <-> qdisc
> relationship between versions.
No, we didn't.

I still don't get how you wish to add more parameters if there is a need to=
 do=20
so. Adding new policies is an overkill if addition of new parameters just=20
extends existing functionality and does not create something completely new=
=20
and incompatible.

I'd be grateful if you could sketch how do you wish to add new "timeout"=20
parameter. Kernel implementation is not particularly important to me right =

now. I would like to know how applications are supposed to use DCCP in 4=20
scenarios:
1. The application wants to use the old behaviour (that is simple policy wi=
th=20
no parameters).
2. The application wants to use prio policy but needs no parameters.
3. The application wants to attach priority information to each packet.
4. The application wants to attach priority and timeout information to each=
=20
packet. If kernel cannot process timeout then fall back to priority=20
information only.
--=20
Regards,
Tomasz Grobelny
