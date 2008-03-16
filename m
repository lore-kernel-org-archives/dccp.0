From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 16 Mar 2008 12:34:47 +0000
Subject: Re: packet priorities
Message-Id: <200803161334.47365.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Saturday 08 of March 2008, Gerrit Renker napisa=B3:
> I am interested in seeing at least a subset of Ian's work realised and I
> am also interested in your plans.
>=20
I've written a few lines of code that might be worth discussing. Available =
at=20
http://dccp.one.pl/svn/. Sorry that it's Subversion but I'm not entirely=20
comfortable with git (yet). Now a few lines of description of what's inside:
 * the code for queuing and dequeing packets has been moved to policies,
 * there are two policies: simple and prio,
 * simple policy is the default and is intended to work as before the chang=
es,
 * prio policy's code is ugly and probably slow. But it works and can show =
the=20
benefits using userspace test program,
 * policies can be manipulated both by getsockopt/setsockopt=20
and /proc/sys/net/dccp/policies/

What do you think of the code? What would need to be corrected for inclusio=
n=20
in dccp_exp test tree? I'd be most interested in comments about design and =

interfaces but bug reports and suggestions about better implementation of=20
prio policy are also welcome.
--=20
Regards,
Tomasz Grobelny
