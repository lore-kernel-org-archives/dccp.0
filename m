From: Samuel Jero <sj323707@ohio.edu>
Date: Tue, 01 Mar 2011 06:12:26 +0000
Subject: Re: Proposed NN Feature handling modification
Message-Id: <1298959946.3728.34.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-itdZm7DoVwP1Fuen+Fgg"
List-Id: <dccp.vger.kernel.org>
References: <1297648146.9816.149.camel@jero-laptop>
In-Reply-To: <1297648146.9816.149.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-itdZm7DoVwP1Fuen+Fgg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> Thank you for sending the updates. I have applied them to the current tre=
e,
> please check them. Here are the changes that I made:
>=20
>   Patch #1: only whitespace changes. When looking over this patch I noted=
 a problem
>             with setting the local sequence window directly: this is also=
 done in=20
>             feat.c:dccp_hdlr_seq_win() - in particular, also adjusting GS=
S, AWL, AWH.
>             Please see discussion below, this is related.

Good catch. We should call dccp_update_gss() to adjust the GSS, etc.
However, since dccp_hdlr_seq_win() will be called almost immediately
after we set the value directly, not adjusting the GSS, etc at this
point won't actually be noticed.

Considering that the assignment will go away shortly (your new patch)
and that it doesn't actually affect performance, I don't think this is
worth fixing now.

>   Patch #4: I think your patch set has tackled some of the problems menti=
oned
>             in the FIXME that it removes. It would be good to find out wh=
at
>             remains to be tackled, to eventually remove the #ifdef.

That's on my list of things to do eventually.

>   Patch #5: Added a dccp_feat_list_pop(entry) in case the new value overw=
rites
>             an existing one. Otherwise there would be multiple ChangeL op=
tions
>             in the same packet, with differing values. Please also see be=
low.

I believe dccp_feat_entry_new(), which is called from
dccp_feat_push_change(), already takes care of an existing option by
calling the destructor and reallocating the feature. That said, I don't
really have a problem with the change.


> I am therefore sending an RFC patch separately. Although I have tried it =
briefly
> with some Speex-streaming yesterday, I have not yet applied it to the tes=
t tree:
> could you give this one a brief spin with your test setup?

Excellent. I am always in favor of RFC compliance; if the code is
simpler, so much the better. I will try to test this patch in the next
few days.


> | It just seems to me that there should be a better way to do this;
> | something that's clearer and easier to understand/debug.=20
> |=20
> I wonder if there are any corner cases with waiting for the ConfirmR opti=
on before
> activating the case: if not, the case is simpler, and I think we can then=
 even=20
> remove the following (changed) segment.
>=20
>         entry =3D dccp_feat_list_lookup(fn, feat, 1);
>         if (entry !=3D NULL) {
>                 if (entry->val.nn =3D=3D fval.nn)
>                         return 0;
>                 dccp_pr_debug("Clobbering existing NN entry %llu -> %llu\=
n",
>                               (unsigned long long)entry->val.nn,
>                               (unsigned long long)nn_val);
>                 dccp_feat_list_pop(entry);
>         }

I have actually done a little work on a patch similar to the one you
sent out. It turns out that there is at least one corner case.

Consider this scenario: Sender has ack ratio=3D1 and then starts feature
negotation for ack ratio=3D2. At this exact time, the sender goes idle.
This triggers the RTO timer, which will check the ack ratio and reset it
to 1 if it is larger. However, this code has no way of knowing that we
are currently negotiating for ack ratio=3D2. As a result, the first packet
sent after the idle period will change the ack ratio at the receiver to
2. With cwnd at 1, the sender will wait for the RTO to send a second
packet which will trigger an ack. The good news is that this ack will
confirm ack ratio=3D2, so the next RTO will start feature negotiation for
ack ratio=3D1 and this fixes the problem.

I think in order to implement this, we need two ack ratio (and possibly
other feature) variables. An ack_ratio_current (updated on confirm) and
an ack_ratio_next (updated on start of feature negotiation). That way,
code that checks for ack ratio larger than cwnd can utilize
ack_ratio_next to prevent a problem like above. However, code
interpreting acks and sending acks can use the current value.


Samuel Jero
Internetworking Research Group
Ohio University

--=-itdZm7DoVwP1Fuen+Fgg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1sjkcACgkQEwoGUlJjrt+dUACgowFKxq/1LJnlhDcMSkWIXLWr
VzYAnjml1JtzJvlT/ShFB0gCTnC51QpS
=5yoS
-----END PGP SIGNATURE-----

--=-itdZm7DoVwP1Fuen+Fgg--
