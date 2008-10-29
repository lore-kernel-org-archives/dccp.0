From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 29 Oct 2008 05:21:18 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: Ignore packets with specific priority
Message-Id: <20081029052118.GA6412@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200810262233.54649.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200810262233.54649.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| This trivial patch allows qpolicies to be moved to userspace as demonstra=
ted=20
| by attached C# code (requires mono). This way userspace-kernelspace inter=
face=20
| is dead simple allowing for quite a lot flexibility in designing the way =

| packet buffer is organized.
=20

| The basic idea is that we set send buffer size so that only one packet fi=
ts in=20
| it. Sending second packet while first is inside buffer (has not been sent=
=20
| yet) causes send() to block until ccid allows the first packet to be 'sen=
d'.=20
One difficulty that I see is what to do when the send socket is non-blockin=
g.

| For each real packet we call send() twice: one 'fake' (will be discarded =
just=20
| before sending) and one 'real' (contains user data). This makes all the=20
| waiting to be done on the 'fake' packet making sending the real one reall=
y=20
| fast. This allows for late data choice without difficult to implement rin=
g=20
| buffers shared by user and kernel space or complicated qpolicies code on =

| kernel side.
Maybe purists will not like this since the complexity is now shifted to the
user-kernel interface. But it may well be a start to develop some kind of
new interface which achieves the same in a cleaner way.

In any case, if people would like to test this feature, I'd be happy to fork
a new qpolicy subtree from the test tree.

=20
| Results on CCID2 are very promising (near ideal), but CCID3 is somewhat=20
| disappointing to the extent I'm starting to think that I'm doing somethin=
g=20
| seriously wrong while testing it.
|=20
Can you please narrow down what is happening with CCID-3.  CCID-3 is very
complicated and sensitive, so it is possible that the problem is within
CCID-3 and not the qpolicy code - need more detailed information.


| Therefore I have two questions:
| 1. What do you think about the idea in general?
| 2. Could anybody test the attached code on both CCID2 and CCID3 and send =

|    results/observations to the list?
|=20
At the moment this is just enough code to allow a what seems to me working
proof-of-concept implementation.=20

I don't have mono installed and need to prioritise with time - the highest
priority at the moment is to keep the test tree up to date and bug-free.

If a stable interface evolves out of this development work, it would be
great to integrate it with the existing (C flat) code
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#DCCP_Library


| --- a/net/dccp/qpolicy.c
| +++ b/net/dccp/qpolicy.c

| @@ -120,11 +122,11 @@ struct sk_buff *dccp_qpolicy_pop(struct sock *sk)
|  {
|  	struct sk_buff *skb =3D dccp_qpolicy_top(sk);
| =20
| -	/* Clear any skb fields that we used internally */
| -	skb->priority =3D 0;
| -
| -	if (skb)
| +	if (skb) {
| +		/* Clear any skb fields that we used internally */
| +		skb->priority =3D 0;
|  		skb_unlink(skb, &sk->sk_write_queue);
| +	}
|  	return skb;
|  }
Thank you for the above hunk -- since it fixes in fact a potential source of
trouble, I have merged it into the patch entitled "dccp: Policy-based packet
dequeueing infrastructure" and updated the test tree to use this patch.
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h=FFc6589ad8fb51edb37f31cbad9b913e9b47f630
