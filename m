From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 18 Jun 2008 20:46:15 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806182246.15433.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Wednesday 18 of June 2008, Gerrit Renker napisa=B3:
> | > In the kernel I think it is best to make it type-safe, i.e. no new
> | > parameters to already-defined policies. But I can't see how this would
> | > restrict the use.
> | > (...)
> |
> | So we would need new policy for each new parameter, right? I somehow
> | don't like it but it should work. You are right that this way runtime
> | parameter discovery is not necessary. BTW, we will have a bit of a
> | problem with naming qpolicies ;-)
>
> Yes, not claiming that my suggestions were very good.
>
> By the way, did you notice that the matrix was incomplete - timeout
> standalone was missing, the corrected version would look something like
>
Well, I assumed that you did that on purpose because that would imply that =
we=20
need more or less N policies for N parameters added one at a time. When we =

want separate policy for just timeout we end up with 2^N policies. And that=
=20
would be just mad because the same effect can easily be achieved with setti=
ng=20
priority to the same value on all packets.

>     +-------------+--------+-------------------+------------------+
>
>     | Policy Name | Policy |         Presence of Parameters       |
>     |
>     |             | ID#    | DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT |
>
>     +-------------+--------+-------------------+------------------+
>
>     | "simple     |   0    |        no         |        no        |
>     | "prio"      |   1    |       YES         |        no        |
>     | "timeout"   |   2?   |        no         |       YES        |
>     | "timed-prio"|   3?   |       YES         |       YES        |
>
>     +-------------+--------+-------------------+------------------+
>
> There is a special trick for the aggregate "timed-prio" policy: it is
> the logical-OR of the "prio" and "timeout" policy IDs. Perhaps composite
> policy IDs could be defined in this way.
>
Then we would have straight mapping between possible parameters and policy =

numbers. That is, effectively we would not set the policy number but reques=
t=20
the capability of processing certain parameters, right? So that the=20
application could specify 0, DCCP_SCM_PRIORITY, DCCP_SCM_TIMEOUT or=20
DCCP_SCM_PRIORITY|DCCP_SCM_TIMEOUT as the policy ID?

Could be nice, but what happens if we have two policies with the same set o=
f=20
supported parameters? How do we differentiate them? In the above: how do we=
=20
diffrentiate between simple policy (which doesn't have any parameters ever)=
=20
and prio policy with no parameters (just because we don't need to provide a=
ny=20
for one particular case)?

> | I will for sure be working on some apps to demonstrate how the new
> | interface can be used. But first I need to create a simple server/client
> | transmitting G.726 encoded voice over UDP/RTP (any hints on that?)...
>
> Tommi Saviranta has been working on a DCCP port for SpeexComm:
> 	http://tuomas.kulve.fi/projects/speexcomm/
> The port is available via SVN:
> 	svn co http://tuomas.kulve.fi/svn/speexcomm
>
> Leandro Sales de Melo has developed a DCCP plugin for gstreamer and used
> it with VoIP/speex. It comes with example applications for these:
> https://garage.maemo.org/frs/?group_id)7
> https://garage.maemo.org/projects/ephone
> http://www.mail-archive.com/dccp@vger.kernel.org/msg03101.html
>=20
I'll have a look at these. It seems that GStreamer is the way to go. Howeve=
r,=20
there is a minor glitch. GStreamer doesn't support a clean way of passing=20
priority data between plugins, so the code will probably be a bit ugly.
--=20
Regards,
Tomasz Grobelny
