From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 05 Jan 2007 16:31:35 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <200701051631.35335@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  Um, you misunderstand. =A0The problem that Ian's patch addresses seems=20
|  entirely within the purview of RFC 3448/4342. =A0He is not trying to=20
|  innovate. =A0Recalculating the loss rate after a longer period of non-lo=
ss=20
|  is NOT EXPERIMENTAL it is REQUIRED. =A0The loss event rate is NOT=20
|  calculated ONLY when losses are detected. =A0It must be calculated on=20
|  every feedback packet. =A0I don't have time at the moment to look up=20
|  chapter and verse, maybe later.
Please take another look at the patch: what you are saying is true but appl=
ies to the _sender_, but Ian's
code is entirely within the _receiver_. We are not at 4342 yet, at the mome=
nt the receiver calculates
the loss event rate and then contacts the receiver.

Can you please look up chapter and verse -- I have read all related documen=
ts and can only identify
section 5.4 of RFC 3448. With regard to this, we are in agreement: this nee=
ds to be audited to be conform.

But with regard to recalculating the loss rate after a longer period of non=
-loss:=20

 =3D> either there is indeed a reference for this in the current RFCs (it i=
s not [RFC 3448, 5.4] and not the
     corresponding section in 3448bis) but then neither Ian nor I have foun=
d this

 =3D> or there is no such reference and then we should clearly separate the=
 issues into (a) making sure that
     the code complies to [RFC 3448, 5.4] and (b) what do we do with the "r=
ecalculating the loss rate after
     a longer period of non-loss" ?


|  I think (for what it's worth) his patch should be accepted as is, and=20
|  maybe he, or someone, will simplify the recalc_recalcloss part later.
I agree with the points you raised, but disagree with adding an experimenta=
l part. The reason is that
the CCID 3 module is still seriously broken:

	* from the output of dccp_probe one can see that the entire system is osci=
llating and not
          reaching a stable fixed point; even under ideal, non-loss conditi=
ons
        * the behaviour using tools such as iperf is unpredictable
        * performance is very poor: sometimes, on a good day one gets 50% o=
f the bandwidth, but at other
          test runs the speed goes down to only a couple of Mbits/sec (and =
this with a loss rate of 0)

Therefore my suggestion is for the moment to only put in changes which are =
documented in the RFCs, fix
all these bugs, and add everything else once the basic problems have been s=
orted out.
