From: Samuel Jero <sj323707@ohio.edu>
Date: Thu, 24 Feb 2011 05:25:40 +0000
Subject: Re: [PATCH 0/4]  dccp: Congestion Window > Sequence Window
Message-Id: <1298525140.23100.150.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-dqCfqC6DhtysrFUQMFUu"
List-Id: <dccp.vger.kernel.org>
References: <1297647741.9816.143.camel@jero-laptop>
In-Reply-To: <1297647741.9816.143.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-dqCfqC6DhtysrFUQMFUu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

>The only patch that has an issue is #2: this reintroduces a problem which
> occurred earlier when performing feature negotiation during the initial
> handshake. Since your patch set targets feature negotiation in establishe=
d
> state, there should be a way to enable both - i.e. keep the old behaviour
> for the initial, and use the new one for the established state.

I'm working on slightly modifying the patch to fix this issue. Will
repost shortly.

> Other issues that would be good to resolve before uploading the patches:
>  * some have minor codingstyle issues, I am ok to fix stuff up to some
>    degree; but please consider scripts/checkpatch.pl

I actually did run that script over these patches, and the script
reported no problems. I've re-read the codingstyle document and don't
see anything clearly wrong. What am I doing that's not standard coding
style?

>  * could you add comments (short descriptions) about conditions you obser=
ved,
>    or add pointers to documentation webpages in the commit message? It he=
lps
>    in future discussions to come back on track faster.

I'll do that. Right now, I'm making the changes you suggested to the
patches. I hope to repost them shortly.

Samuel Jero
Internetworking Research Group
Ohio University

--=-dqCfqC6DhtysrFUQMFUu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1l69AACgkQEwoGUlJjrt/p5wCgkaGjJm2gszZ7gau5yMU39uRn
JKgAnRhRmeCsEwX7CWAUyiU+G7ImZzEZ
=CrqD
-----END PGP SIGNATURE-----

--=-dqCfqC6DhtysrFUQMFUu--
