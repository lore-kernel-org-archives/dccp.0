From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 13:14:26 +0000
Subject: Re: [PATCHv2] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <200612011314.26835@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Arnaldo,

many thanks for the detailed feedback - that has taught me some things I di=
d not know.

I will reshape the patch with regards to comments. While at it, would like
to increase resolution up to units of 100ms, with a default value of 10=20
corresponding to the TCP RTO value - as per earlier email by Mark Handley.
=20

|  - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"r_sample=
=3D%uus\n", dccp_role(sk), sk,
|  + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"r_sample=
=3D%us\n", dccp_role(sk), sk,
| =20
|  wrong, as r_sample is in microseconds, it comes from a timeval_delta,
|  that gets it from dccp_timestamp and the elapsed times, originally in
|  tenths of microsoeconds but multiplied by 10 to get back to
|  microseconds.
Disagree with the above, since r_sample is not changed and t_elapsed is
converted from units of 10*microseconds to microsecond by multiplication:

	r_sample =3D timeval_delta(&now, &packet->dccphtx_tstamp);
	t_elapsed =3D dp->dccps_options_received.dccpor_elapsed_time * 10;

I will put that into a different patch, as I am just going over previous on=
es
that I have sent and checking each one of them.
