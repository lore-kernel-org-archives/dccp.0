From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 15 Apr 2007 16:23:15 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <200704151723.15084@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  Thus the RTT measurement is EXPLICITLY fed in to the throughput=20
|  equation. =A0In TCP the RTT measurement mostly just feeds in to the RTO,=
 which=20
|  is why the protocol's behavior is less sensitive to the measurement.
| =20
|  DCCP *MIGHT* work just fine with the inflated RTT measurements (i.e. the=
 RTT=20
|  including IP processing) but there is yet another gerrit missive to work=
=20
|  through to see how real that complaint is.
| =20
|  A less aggressive version of "turn off RTT for LANs" would be simply to =

|  subtract an estimate of the IP<->card path's cost from the measured coar=
se=20
|  RTT. =A0This would fix the problem. =A0If you used a stable minimum esti=
mate, the=20
|  RTT would naturally "inflate" when the host was busy, which as Ian point=
s out=20
|  is what we actually want. =A0How to obtain an estimate? =A0Probably anyt=
hing would=20
|  do, including something derived at boot time from BogoMIPS.
Such an estimate is difficult to obtain - I get completely different result=
s on
different computers; depending on the card (ee100 with NAPI is fine, my che=
apo RTL 8139
on the other hand makes a lot of noise). Some practical figures are:

 * when the timestamps get taken at arrive time, the RTT values are very cl=
ose to what ping
   reports (e.g. 100 ... 1,100 usec on a LAN);

 * when the timestamps get taken in the CCID3 module, the RTT values are ro=
ughly up to 10
   times larger (5 milliseconds on a link with a 500usec link RTT was frequ=
ently the case)

