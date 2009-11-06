From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 06 Nov 2009 00:52:23 +0000
Subject: Re: [PATCH 1/4] Adds random ect generation to tfrc-sp sender side
Message-Id: <cb00fa210911051652o1f8b26bdia549ac97f1b4ce13@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B790.9000701@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B790.9000701@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, Oct 26, 2009 at 4:55 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrot=
e:
> | > =A0 =A0That is, at the moment both the sender and receiver side of th=
e ECN Nonce
> | > =A0 =A0sum verification are placeholders which currently have no effe=
ct.
> | >
> |
> | Okay, then the implementation would be useless now.
> I was not suggesting to throw away the patches, we can keep them for
> later use.
>
> They are a good starting basis once it makes sense to work with ECN.
> Or how can we test ECN if we are not sure that the other parts work
> as they are supposed to?
>

Okay, we'll keep the patches.

> | > =A03) Starting an implementation throws up further questions that nee=
d to
> | > =A0 =A0be addressed, both the basis and the extension need to be veri=
fied.
> | >
> | > I would like to suggest to implement the basis, that is CCID-4 with E=
CN
> | > (using plain ECT(0)), test with that until it works satisfactorily, a=
nd
> | > then continue adding measures such as the ECN Nonce verification.
> | >
> |
> | Okay. But, when would be good to at least include random ECT
> | generation? When DCCP ECN code will get fixed? Is there any work on
> | this?
> |
> I asked this on netdev earlier, there was not much enthusiasm.
>
> The issue is that ECN belongs both to the network and the transport layer.
> This network layer is in inet_ecn.h, outside of DCCP.
>
> I believe that the changes would not be too hard to do, by changing the
> macros. But it requires working with the people on netdev, in particular
> to ensure it does not break something in the TCP/SCTP subsystems (both
> also use ECN, and then there are also raw sockets).
>
> I also have an interest in resolving this, due to the ugliness at the
> moment for enabling ECN on IPv6.
>
> RFC 2884, written by one of the Linux ECN developers, describes early
> IPv4 ECN evaluation. It seems that initially it was planned to only
> support ECN over Ipv4, parts of the code may be still from that time.
>
> We can pursue this in parallel to the other issues. Ideally this would be
> resolved at the time the other parts of CCID-4 are ready for testing.
>

Ok.

> | > In summary, I would like to suggest to remove the ECN verification for
> | > the moment and focus on the "basic" issues first.
> | >
> | > Would you be ok with that?
> | >
> |
> | Yes, we'll keep the ECN verification code here at our git until the
> | scenario is ready.
> |
> I was going to suggest to put them onto a webpage, such as yours, or on
> www.erg.abdn.ac.uk/users/gerrit/dccp there is also still some space.
>
> Can you please elaborate how to keep your git tree and the one on
> eden-feed synchronized? At the moment I have not made any changes other
> than the ones I emailed you about. Is there a way of keeping both trees
> in synch without running into versioning difficulties?
>
> (The simplest way I can think of is to keep the patches in a separate
> =A0set, or to spawn a subtree which contains the ECN patches on top of the
> =A0CCID-4 tree.)
>

Ok, we'll put the patches at our webpage. And about the git, I can't
think a better way too.

>
> | > (Also for later) I wonder how to do the sums, with RFC 3168
> | > ECT(0) =3D 0x2 =3D> !0x2 =3D 0
> | > ECT(1) =3D 0x1 =3D> !0x1 =3D 0
> | >
> |
> | I don't understand. Can you try to explain it? Or cite RFC section
> | that address it?
>
> The values are from figure 1, page 7, the expressions evaluate both as 0:
>
> void main(void)
> {
> =A0 =A0 =A0 =A0printf("!0x2 =3D %d, !0x1 =3D %d\n", !0x2, !0x1);
> }

Thanks.



--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Putt's Law:
       Technology is dominated by two types of people:
               Those who understand what they do not manage.
               Those who manage what they do not understand.
