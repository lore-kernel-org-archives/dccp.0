From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 09 Apr 2008 17:39:47 +0000
Subject: Re: [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <200804091939.47401.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 09 of April 2008, Gerrit Renker napisa=B3:
> But it is not really a problem. The above section is within the #ifdef
> __KERNEL__ so afaik is not visible to userland. So, yes, option (b) is
> the only alternative - maybe Arnaldo has a better suggestion.
>
Right. But then if struct dccp_sock is neither visible from userland, nor i=
s=20
it used in any other part of the kernel then why not move it to=20
net/dccp/dccp.h?
--=20
Regards,
Tomasz Grobelny
