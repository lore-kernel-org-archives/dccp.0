From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 12:16:53 +0000
Subject: Re: [PATCH v2  4/5]: Rate-limit DCCP-Syncs
Message-Id: <200709251316.53262@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709251058.41805@strip-the-willow>
In-Reply-To: <200709251058.41805@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org


|  > +/* rate-limit for syncs in reply to sequence-invalid packets; RFC 434=
0, 7.5.4 */
|  > +int sysctl_dccp_sync_ratelimit=A0=A0=A0=A0=A0=A0=A0__read_mostly =3D =
HZ / 8;
| =20
|  Why the extra spaces/tabs before __read_mostly?=20
This is for consistency with the sysctls below, the whole paragraph looks l=
ike this:

/* the maximum queue length for tx in packets. 0 is no limit */
int sysctl_dccp_tx_qlen         __read_mostly =3D 5;

/* sysctl variables governing numbers of retransmission attempts */
int sysctl_dccp_request_retries __read_mostly =3D TCP_SYN_RETRIES;
int sysctl_dccp_retries1        __read_mostly =3D TCP_RETR1;
int sysctl_dccp_retries2        __read_mostly =3D TCP_RETR2;

/* rate-limit for syncs in reply to sequence-invalid packets; RFC 4340, 7.5=
.4 */
int sysctl_dccp_sync_ratelimit  __read_mostly =3D HZ / 8;

Sigh - I just wanted to be `neat', but each maintainer has a different conc=
eption of that :)

|  One more:=20
|  In linux networking code what has been the most accepted form for
|  multiline expressions is:
| =20
|  =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (time_after(now, (dp-=
>dccps_rate_last +
|  =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0 sysctl_dccp_sync_ratelimit))) {
| =20
|  Either form produces the same code, but as the later is what I, David
|  and others are most confortable with and have been using for quite a
|  while,=20
Please excuse my ignorance: that was simply something I didn't know, and th=
us it is good that
it is on the list, so that others can also adapt this. Thanks for explainin=
g.

It is _very_ important since in CCID3/CCID4 variable names are all very lon=
g (the drafts are
also long), and lots of calculations.

Will fix that and put the result in the tree.
