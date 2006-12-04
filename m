From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Dec 2006 21:25:16 +0000
Subject: Re: [PATCH] DCCP: handle EAGAIN case
Message-Id: <200612042125.16808@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612031538.27300@strip-the-willow>
In-Reply-To: <200612031538.27300@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  And then as I write this =A0realise we are being way too complicated. We
|  should remove timeo altogether!!! As we are doing this in effect by
|  that continue and that is perfectly valid is this is blocking I/O. So
|  we remove timeo, remove DCCP_XMIT_TIMEO and simplify it a fair bit.
Your idea seems nice and to me it also seemed that it should be simplified.
 =20
|  Still thinking about why we are getting EAGAIN and suspect it is due
|  to you not having that patch but I'll probably add more debugging in.
No, I have that patch in my code:
	if (err > 0) {
			if (!block) {
				sk_reset_timer(sk, &dp->dccps_xmit_timer,
						msecs_to_jiffies(err)+jiffies);
				break;
			} else {
				err =3D dccp_wait_for_ccid(sk, skb, &timeo);
				timeo =3D DCCP_XMIT_TIMEO;          /* <=3D=3D I think you mean this on=
e */
			}


=20
|  Anyway feel free to write a patch or I might when I get home from work
|  or tomorrow
I'd be happy to see a patch - maybe several cases can be folded into one.
