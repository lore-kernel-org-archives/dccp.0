From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 08 Mar 2008 13:27:42 +0000
Subject: Re: packet priorities
Message-Id: <200803081427.43013.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Saturday 08 of March 2008, napisa=B3e=B6:
> 2008/3/8 Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>:
> >  The deadline is not that easy to determine due to client side bufferin=
g.
> > At least that would require cooperation on receiving side. For now I ju=
st
> > assume that some packets are simply more important than others. That is
> > they convey more information to the one who is watching. When streaming
> > football match you are probably less interested in voice comments, music
> > and applause and more about "where is the ball?" (video more important).
> > But when watching the news usually audio is much more important than the
> > object on video that you've already seen thousands of times.
>
> You can track the rtt and also mark the expiry time and do the maths.
> Again check my papers...
I think we don't understand each other well here. My point is that no matte=
r=20
what the kernel does it cannot always know whether packet will be late or=20
not. That is because it would need feedback from client how much of the=20
stream is buffered. Suppose that RTT is 10ms but the client code buffered 1=
5=20
seconds of transmission. If the packet was waiting in DCCP send queue for 5=
=20
seconds should we send it or discard? Without feedback from the player we=20
cannot tell.
In some applications it is possible to assume some sensible defaults or=20
negotiate delay. But that is not a priority for me for now. But of course t=
he=20
design should allow specifying deadline.
--=20
Regards,
Tomasz Grobelny
