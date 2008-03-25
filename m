From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 25 Mar 2008 00:13:32 +0000
Subject: Re: dccp bugs
Message-Id: <200803250113.32575.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 24 of March 2008, Gerrit Renker napisa=B3:
> | > | > Can you try the `ss' command from the iproute package when the
> | > | > problem occurs, using `ss -nadep' to display the DCCP states?
> | > |
> | > | $ ss -nadep
> | > | State       Recv-Q Send-Q                        Local Address:Port
> | > | Peer Address:Port
> | > | FIN-WAIT-1  0      0                                 127.0.0.1:2008
> | > | 127.0.0.1:29792  ino:0 sk:d301d3c0
>
> <snip>
>
> This is a good point, but now it gets confusing. The FIN-WAIT-1/active
> CLOSEREQ state can only happen on the server, so maybe the above output
> is not the right one.
I checked it once again and it looks almost the same. But even if the serve=
r=20
is dead its socket is not that dead. At least it cannot be reused by other =

instance of server.
--=20
Regards,
Tomasz Grobelny
