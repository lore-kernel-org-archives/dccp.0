From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 25 Mar 2008 00:03:08 +0000
Subject: Re: dccp bugs
Message-Id: <200803250103.08124.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 24 of March 2008, Arnaldo Carvalho de Melo napisa=B3:
> IIRC Thomas said that the server process terminates, its just the client
> that hangs for a long time, lemme re-read the other messages...
Yes, you are right.

> Thomas, is it the client that hangs? Or is it the server?
>
It is the client (the program that does connect(...)) that hangs. The serve=
r=20
(the one which does listen(...)) is already dead. Well, the server process =

finished execution but the socket is somehow busy: when I try to run the=20
server once again (on the same port) and try to connect to it with another =

instance of the client program I always get this 32 return code from sendms=
g=20
call.
--=20
Regards,
Tomasz Grobelny
