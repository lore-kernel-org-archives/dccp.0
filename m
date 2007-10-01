From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 10:54:27 +0000
Subject: Re: [PATCH 3/10]: Dedicated auxiliary states to support passive-close
Message-Id: <200710011154.27825@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200707121523.40095@strip-the-willow>
In-Reply-To: <200707121523.40095@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > [DCCP]: Dedicated auxiliary states to support passive-close
|  >=20
|  > This adds two auxiliary states to deal with passive closes:
|  > =A0 * PASSIVE_1 (reached from OPEN via reception of Close) and
|  > =A0 * PASSIVE_2 (reached from OPEN via reception of CloseReq)
| =20
| =20
|  Perhaps we should rename PASSIVE_1 (magic number) to PASSIVE_CLOSEREQ
|  and PASSIVE_2 to PASSIVE_CLOSE, and also CLOSEREQ to ACTIVE_CLOSEREQ?
No problems with the first two. With the third I was initially thinking
`this name is from the RFC', but the RFC didn't help much here and your
scheme makes the state much clearer - so, yes, I agree fully with that.
=20
|  I'll defer these patches till we get some more discussion. There are
|  many more unrelated patches to work on after all :)
What kind of discussion were you thinking of: in a previous thread Ian and I
reached some agreement already that there is a problem here.

The problem really is in taking the RFC 4340 state machine at face value: i=
f this
is done literally, short-lived connections will wipe the receive queue befo=
re the
userland application had a chance to read data; as documented on
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/
If you don't believe this, it can readily be tested by writing a small test=
 app which=20
sends something like `hello world' to the server.
All data is seen on the wire, but never by the application.

A test app can be found in the directory misc/hello_world of
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/dccp_applications_lib.tar.=
gz
