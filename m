From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Dec 2006 07:15:58 +0000
Subject: Re: [BUG] CCID3 performance
Message-Id: <200612040715.58328@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
In-Reply-To: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  > So here are the stats using iperf:
|  > Test =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 2.6.19rc6+ian
|  > 2.6.20-acme20
|  > Direct connect =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A087 Mbits =A0 =A0 =A0 =A0 =A0 =A0 36 Mbits
|  > Through a Linux router (1.2 ms rtt) =A0 =A036 Mbit =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 200 kbits
|  > (yes that is correct!)
|  > Through netem (100 ms rtt, 5% loss) =A0130 kbits =A0 =A0 =A0 =A0 =A0 1=
16 kbits (OK)
|  >
|  I've been trying to track this down to any individual patch and I'm
|  going crazy! With my code (2.6.19rc6+my patches) now I'm getting the
|  same bad numbers as for 2.6.20-acme20
I can confirm this - it seems sometimes as if the code in a fuzzy way needs=
 to `warm up'.
Also I can not test at home with my older equipment - DCCP is too demanding=
 on CPU speed;
the top performance even with CCID2 is 15Mbits/sec.
Therefore the more experience/performance reports come in, the better for u=
nderstanding
what is going on.
