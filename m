From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 17 Jun 2008 20:28:05 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <200806172228.06801.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 17 of June 2008, Gerrit Renker napisa=B3:
> | In other words the basic question is: do we want to add new parameters =
to
> | existing qpolicies (then we need parameter discovery) or we don't want
> | new parameters (then we don't need information about parameters availab=
le
> | at runtime).
> |
> | Having defined the alternatives it's time to decide which is better. I,
> | of course, claim that mine (which is adding new parameters to existing
> | qpolicies). That's simply because I think that providing both
> | DCCP_SCM_TIMEOUT and DCCP_SCM_PRIORITY parameters may be useful. And I
> | don't see an obvoius way of achieving that goal with "new policy for new
> | parameter" approach.
>
> I agree that providing both parameters may be useful, but don't see this
> as a place of contradiction.
>
> In the kernel I think it is best to make it type-safe, i.e. no new
> parameters to already-defined policies. But I can't see how this would
> restrict the use.
> (...)
>
So we would need new policy for each new parameter, right? I somehow don't =

like it but it should work. You are right that this way runtime parameter=20
discovery is not necessary. BTW, we will have a bit of a problem with namin=
g=20
qpolicies ;-)

> | > With a manpage I mean to document
> |
> | Is there any "man dccp"?
>
> Not yet. If you or someone else can find time to contribute towards a DCCP
> manpage, that would be just great. The best available information so far =
is
> on the OSDL pages for DCCP and Documentation/networking/dccp.txt.
>
But it's not in kernel sources? Then probably a new page would not be accep=
ted=20
as it would describe an experimental API. The above mentioned dccp.txt is=20
probably the best place for now.

> I think there is a special maintainer for the kernel manpages, who could
> be emailed with a basic manpage. But ther ere is a similar problem - if t=
he
> API changes frequently, then this requires to update the manpage
> accordingly.
>
I guess these would mostly be API additions, without any incompatible chang=
es.

> As alternatives to documentation, there are for example providing
>  *running source code,
I will for sure be working on some apps to demonstrate how the new interfac=
e=20
can be used. But first I need to create a simple server/client transmitting=
=20
G.726 encoded voice over UDP/RTP (any hints on that?)...

>  * web pages or
Is there any official, publicly editable DCCP wiki? I'd rather not create y=
et=20
another page...
--=20
Regards,
Tomasz Grobelny
