From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Feb 2011 11:24:49 +0000
Subject: Re: Proposed NN Feature handling modification
Message-Id: <20110228112449.GD3620@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1297648146.9816.149.camel@jero-laptop>
In-Reply-To: <1297648146.9816.149.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Samuel Jero:
| > | My recommendation is to wait until the Confirm has been received to
| > | alter the value of an NN feature. This eliminates the problem above a=
nd
| > | has the advantage that it follows RFC 4340 (section 6.6.1). Further,
| > | making this change should require little code change.
| > |=20
| > I like the solution introduced in patch #3 because it is simple: Change
| > options are retransmitted until the correct Confirm option comes in,
| > instead of resetting the connection. It is an instance of the robustness
| > principle - the peer can send any outdated/reordered Confirm option.
|=20
| Patches #2 and 3 (and another patch I will send shortly) make the
| current method usable. Without them, NN feature negotiation in an
| ongoing connection causes the connection to be reset.
|=20
Thank you for sending the updates. I have applied them to the current tree,
please check them. Here are the changes that I made:

  Patch #1: only whitespace changes. When looking over this patch I noted a=
 problem
            with setting the local sequence window directly: this is also d=
one in=20
            feat.c:dccp_hdlr_seq_win() - in particular, also adjusting GSS,=
 AWL, AWH.
            Please see discussion below, this is related.
  Patch #4: I think your patch set has tackled some of the problems mention=
ed
            in the FIXME that it removes. It would be good to find out what
            remains to be tackled, to eventually remove the #ifdef.
  Patch #5: Added a dccp_feat_list_pop(entry) in case the new value overwri=
tes
            an existing one. Otherwise there would be multiple ChangeL opti=
ons
            in the same packet, with differing values. Please also see belo=
w.

  http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dsho=
rtlog;h=DCcp

| However, I wouldn't consider them a fix for what I'm talking about here.
| The fact is that with the current code the sender thinks the receiver
| has the new value of the feature while the feature is being negotiated.
|=20
I think this was my fault: the RFC says in 6.6.1 that values MUST not be ch=
anged
until they are confirmed by the peer. When this is taken as a prerequisite,=
 the
complexity you mentioned below and the weird cases of two ends being in a l=
imbo
state will not appear.

I am therefore sending an RFC patch separately. Although I have tried it br=
iefly
with some Speex-streaming yesterday, I have not yet applied it to the test =
tree:
could you give this one a brief spin with your test setup?

If it works out as expected, I think this will give a simpler (and more con=
formant)
solution.

| Particularly for the Ack Ratio this can be confusing because the sender
| would interpret the acks from the receiver using the new ack ratio. The
| first half RTT of those would be from the old ack ratio. This would
| cause inappropriate changes in the congestion window/pipe except for
| appropriate byte counting which, I believe, mitigates that.
|=20
| It just seems to me that there should be a better way to do this;
| something that's clearer and easier to understand/debug.=20
|=20
I wonder if there are any corner cases with waiting for the ConfirmR option=
 before
activating the case: if not, the case is simpler, and I think we can then e=
ven=20
remove the following (changed) segment.

        entry =3D dccp_feat_list_lookup(fn, feat, 1);
        if (entry !=3D NULL) {
                if (entry->val.nn =3D fval.nn)
                        return 0;
                dccp_pr_debug("Clobbering existing NN entry %llu -> %llu\n",
                              (unsigned long long)entry->val.nn,
                              (unsigned long long)nn_val);
                dccp_feat_list_pop(entry);
        }
