From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 21 Oct 2009 13:15:10 +0000
Subject: Re: [PATCH 1/4] Adds random ect generation to tfrc-sp sender side
Message-Id: <cb00fa210910210615v409d09c6p34cd6a48c48196f5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B790.9000701@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B790.9000701@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, Oct 19, 2009 at 2:23 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrot=
e:
> | Adds random ect generation to tfrc-sp sender side.
>
> I thought about this and found several reasons why it would be better to
> defer ECN Nonce sums to a later implementation.
>
> =A01) At the moment the code always sets ECT(0). Even if it would
> =A0 =A0alternate ECT(0) and ECT(1), this would later be overwritten by EC=
T(0)
> =A0 =A0in dccp_msghdr_parse(). Ok, this could be fixed, but the real prob=
lem
> =A0 =A0is that the underlying machinery does not support ECN nonces, since
>
> =A0 =A0* ECN / DiffServ information is in two separate places of the
> =A0 =A0 =A0inet_sock (u8 `tos' field and u8 `tclass' field of ipv6_pinfo);
>
> =A0 =A0* the ECN driver sits in include/net/inet_ecn.h as
> =A0 =A0 =A0#define INET_ECN_xmit(sk) do { inet_sk(sk)->tos |=3D INET_ECN_=
ECT_0; } while (0)
>
> =A0 =A0* hence this would need to be revised and the best way to make an
> =A0 =A0 =A0acceptable suggestion would be a coded proof of concept that
> =A0 =A0 =A0changing the underlying implementation does have benefits.
>
> =A0 =A0On the receiver side the situation is the same. The function
> =A0 =A0tfrc_sp_check_ecn_sum(), introduced in Patch 2/4 of the TFRC-SP se=
nder
> =A0 =A0implementation is only referenced in Patch 2/2 of the CCID-4 set, =
where
> =A0 =A0it ends, without side effect in "TODO: consider ecn sum test fail".
>
> =A0 =A0That is, at the moment both the sender and receiver side of the EC=
N Nonce
> =A0 =A0sum verification are placeholders which currently have no effect.
>

Okay, then the implementation would be useless now.

>
> =A02) As far as I can see the ECN Nonce is an optimisation, an
>
> =A0 =A0 =A0"optional addition to Explicit Congestion Notification [RFC316=
8]
> =A0 =A0 =A0 improving its robustness against malicious or accidental
> =A0 =A0 =A0 concealment of marked packets [...]" (from the abstract)
>
> =A0 =A0Hence if at all, we would only have a benefit of adding the ECN No=
nce
> =A0 =A0verification on top of an already verified implementation.
>

Yes, not priority at all. And you're right, no benefit.

> =A03) Starting an implementation throws up further questions that need to
> =A0 =A0be addressed, both the basis and the extension need to be verified.
>
> I would like to suggest to implement the basis, that is CCID-4 with ECN
> (using plain ECT(0)), test with that until it works satisfactorily, and
> then continue adding measures such as the ECN Nonce verification.
>

Okay. But, when would be good to at least include random ECT
generation? When DCCP ECN code will get fixed? Is there any work on
this?

> Nothing is lost, once we are at this stage we can return to this set of
> initial patches and revise the situation based on the insights gained
> with ECT(0) experience.
>
> In summary, I would like to suggest to remove the ECN verification for
> the moment and focus on the "basic" issues first.
>
> Would you be ok with that?
>

Yes, we'll keep the ECN verification code here at our git until the
scenario is ready.

>
>
> Appendix
> --------
> | +int tfrc_sp_get_random_ect(struct tfrc_tx_li_data *li_data, u64 seqn)
> | +{
> | + =A0 =A0 int ect;
> | + =A0 =A0 struct tfrc_ecn_echo_sum_entry *sum;
> | +
> | + =A0 =A0 /* TODO: implement random ect*/
> | + =A0 =A0 ect =3D INET_ECN_ECT_0;
> | +
> | + =A0 =A0 sum =3D kmem_cache_alloc(tfrc_ecn_echo_sum_slab, GFP_ATOMIC);
>
> For a later implementation, there should be protection against NULL, e.g.
> =A0 =A0 =A0 =A0if (sum =3D NULL) {
> =A0 =A0 =A0 =A0 =A0 DCCP_CRIT("Problem here ...");
> =A0 =A0 =A0 =A0 =A0 return 0;
> =A0 =A0 =A0 =A0}
> | +
> | + =A0 =A0 sum->previous =3D li_data->ecn_sums_head;
> | + =A0 =A0 sum->ecn_echo_sum =3D (sum->previous->ecn_echo_sum) ? !ect : =
ect;
>

Thanks, i forgot that.

> (Also for later) I wonder how to do the sums, with RFC 3168
> ECT(0) =3D 0x2 =3D> !0x2 =3D 0
> ECT(1) =3D 0x1 =3D> !0x1 =3D 0
>

I don't understand. Can you try to explain it? Or cite RFC section
that address it?

> From the addition table in RFC 3540, section 2,
> ECT(0) + ECT(0) =3D 0
> ECT(0) + ECT(1) =3D 1
> ECT(1) + ECT(1) =3D 0
>
> One way could be
> =A0 =A0 =A0 =A0sum->ecn_echo_sum ^=3D (ect =3D INET_ECN_ECT_1);

Ok.




--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
