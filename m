From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 02 May 2008 20:52:36 +0000
Subject: Re: [DCCP] kernel BUG on connecting
Message-Id: <200805022252.36579.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200805021545.16399.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200805021545.16399.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Friday 02 of May 2008, Gerrit Renker napisa=B3:
> With regard to your bug - did you build the full kernel or just the
> modules? You seem to lack room in the skb, if only the modules were
> built (but not the changed kernel core), this would be a likely cause.
>=20
Yes, indeed. Rebuild helped. Thanks a lot for quick help.
--=20
Regards,
Tomasz Grobelny
