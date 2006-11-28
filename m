From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 20:04:51 +0000
Subject: Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <200611282004.51657@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611281435.05466@strip-the-willow>
In-Reply-To: <200611281435.05466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  I think I didn't explain my point well here. You can't change to u32
|  but need to be unsigned int (not u64).=20
Don't get this: u32 is a 32-bit unsigned value and therefore looks sufficie=
nt - and you
are proposing `unsigned int' to have easier conversion to skb->len, right?

|  u32 is plenty but skb->len gets=20
|  passed into the length parameter... Or that's how I read it anyway.
| =20
|  e.g. net/dccp/output.c dccp_write_xmit:
|  =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0err =3D ccid_hc_tx_send_=
packet(dp->dccps_hc_tx_ccid, sk, skb,
|  =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 skb->len);
|  which then goes through callback to the code in the patch.
OK, what do you suggest:
	a) keep this callback interface, change `len' to `unsigned int'
	b) keep this callback interface, patch as before (use u32)
	c) change the callback interface, get rid of last argument (which is skb->=
len anyway)
           and use `unsigned int' in ccid_hc_tx_packet_sent
       ???
 =20
|  > I have two other suggestions regarding 64-bit unsigned - I think it wo=
uld make sense to store
|  > the calculated send rate in bytes per microsecond, since there are som=
e nasty conversion problems
|  > attached to it, as well as division errors. I am working on this right=
 now.
|  >
|  Disagree if I understand you. This would imply minimum send rate of 1
|  million bytes per second which is often not achievable.
No that is not what I meant. Of course this needs to be done with regard to=
 proper conversion - in
particular, X_recv. I am at the moment trying to write this up (time consum=
ing task), but the gist
of it is - we could eliminate some problems, such as (i) having to multiply=
 by 1E12 when computing
X_calc, (ii) get better results when performing direct division. As said, w=
ill send further information.

Would really appreciate if you could at some time have a look at the moving=
-average patch. Have communicated
with Eddie again about it, and using MSS would at the moment be much more c=
omplicated.
