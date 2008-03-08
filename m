From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 08 Mar 2008 13:34:01 +0000
Subject: Re: packet priorities
Message-Id: <200803081434.01500.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Saturday 08 of March 2008, Gerrit Renker napisa=B3:
> Hi Tomasz,
>
> | The next step would be to use it in VLC stream_out module to make for
> | example sound more important (and thus more likely to arrive to
> | destination endpoint). I played a bit with VLC code and it seems it wou=
ld
> | be possible (some MPEG Transport Stream packet reordering will be
> | necessary).
>
> I have some doubts whether VLC is useful - as far as I know all
> video/audio/subtitle data is internally packaged into a single MPEG-2
> transport stream, so it is not possible to separate/prioritise its parts.
>
The problem is not that it is a single TS, but the fact that TS packets of =

different types are packaged in one DCCP packet. And that's why I've writte=
n=20
that some reordering will have to take place.

> Which version of VLC did you use?
>=20
SVN HEAD. Well, now they switched to git but the last version I tried was f=
rom=20
Subversion.

> A better starting point is mpeg4ip, but it is a chicken-and-egg problem
> as there are no DCCP-enabled servers yet.
>
It may be worth looking at. VLC is not a fixed point of the project, any=20
server that can demonstrate real use for the kernel framework will do.

> Two ideas with regard to reproducing:
>  1. The excellent little D-ITG traffic generator
>     http://www.grid.unina.it/software/ITG/
>     It has DCCP support and packet timing can be set as a random variable,
>     which can be bound to a random seed (to reproduce test runs).
>=20
That might be useful. I'll just have to check if it is possible to count wh=
ich=20
packets arrived at the destination end so that mixed audio/video stream=20
simulation can be done.

> Does your scheme use timeouts for packets? If yes, then part of the
> question is already solved. I can't say what happens with abstract
> priorities, I am assuming you would like to establish a partial ordering
> among the packets, in the way of "if you need to discard packets since
> the link is congested, throw away all packets with priority < P away, if
> that is not possible, tell the application"?
>
Let us put it in more general terms: "throw away the worst packet". What th=
at=20
exactly means should be up to the specific policy (if it turns out that mor=
e=20
than one is necessary).

> my question is - what would be the simplest-possible interface to
> implement and how would it generalise?
>
> With regard to your point (5), Ian was also using a band of priorities.
> In http://wand.net.nz/~iam4/dccp/patches20/30-best_packet_next.diff,
> there is this abstraction:
>
> 	struct dccp_prio {
> 	       struct timeval expiry;
> 	       u16 priority;
> 	       u16 method;
> 	};
>
> When priority =3D 0 then conventional sending is done (enqueue at tail),
> otherwise the `method' field allows different interpretations of the
> priority field.
>
I think that each method or policy should have it's own structure. For the =

simplest policy it could have been non-existant, for the one a bit more=20
advanced it could look as in Ian's patch. But probably without 'method' as =

that should be set on a per socket basis.

> So I guess we can split the problem and worry about the receiver side
> later.
>
That seems to be application level problem because kernel cannot know when =

contents of specified packet is presented to the user. And that would=20
probably have nothing to do with kernel side DCCP code.

> The example of football streaming is good. The problem really stretches
> across several layers:
>  * the user-perceived output (MOS, ITU-T E-model of perceived quality)
>  * the application which streams/receives the data
>  * the socket layer which is controlled by the application
>  * the transport layer which is controlled by the kernel and which is
>    influenced by congestion and current network parameters.
>
> And I think your work targets all three last points.
>
Yes. I'd like to write the kernel layer and demonstarte it on any real worl=
d=20
application.

> I am interested in seeing at least a subset of Ian's work realised and I
> am also interested in your plans. My time is a bit constrained at the
> moment, as I am currently still stuck with fixing some existing CCID-2
> bugs.
It's not my full-time work so it won't be fast. I'd like to have something =

more or less working in April.
--=20
Regards,
Tomasz Grobelny
