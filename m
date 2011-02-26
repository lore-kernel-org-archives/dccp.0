From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 26 Feb 2011 02:04:52 +0000
Subject: Re: Proposed NN Feature handling modification
Message-Id: <1298685892.11418.57.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-Qc+NMFX2x8xt8j9X1OQ7"
List-Id: <dccp.vger.kernel.org>
References: <1297648146.9816.149.camel@jero-laptop>
In-Reply-To: <1297648146.9816.149.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-Qc+NMFX2x8xt8j9X1OQ7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> | My recommendation is to wait until the Confirm has been received to
> | alter the value of an NN feature. This eliminates the problem above and
> | has the advantage that it follows RFC 4340 (section 6.6.1). Further,
> | making this change should require little code change.
> |=20
> I like the solution introduced in patch #3 because it is simple: Change
> options are retransmitted until the correct Confirm option comes in,
> instead of resetting the connection. It is an instance of the robustness
> principle - the peer can send any outdated/reordered Confirm option.

Patches #2 and 3 (and another patch I will send shortly) make the
current method usable. Without them, NN feature negotiation in an
ongoing connection causes the connection to be reset.

However, I wouldn't consider them a fix for what I'm talking about here.
The fact is that with the current code the sender thinks the receiver
has the new value of the feature while the feature is being negotiated.

Particularly for the Ack Ratio this can be confusing because the sender
would interpret the acks from the receiver using the new ack ratio. The
first half RTT of those would be from the old ack ratio. This would
cause inappropriate changes in the congestion window/pipe except for
appropriate byte counting which, I believe, mitigates that.

It just seems to me that there should be a better way to do this;
something that's clearer and easier to understand/debug.=20

> I find it better / more robust to wait for such problems to surface and t=
hen
> tackle them, rather than making the local state change dependent on the o=
ther
> end. Doing this complicates processing since the other endpoint is out of=
 local
> control, hence we need to make assumptions that can break in practice
> (e.g. that a client should reply within two RTTs, but there is a sudden j=
amming
> on the wireless / ADSL, so that the reply comes in only after multiples o=
f
> seconds).

That makes sense. After having run more tests, this issue doesn't seem
to be causing any problems right now. I'm okay with waiting until this
causes a problem to try to come up with a better solution.

Samuel Jero
Internetworking Research Group
Ohio University=20

--=-Qc+NMFX2x8xt8j9X1OQ7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1oX8AACgkQEwoGUlJjrt8K6ACffVKFK5FCL5QmmJ+vpBZXZF8G
MEkAn1HhvAVbCVFg4QPJ+akxCmxp8BVe
=eKD/
-----END PGP SIGNATURE-----

--=-Qc+NMFX2x8xt8j9X1OQ7--
