From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Sep 2006 13:42:07 +0000
Subject: Re: Packet size s on CCID3
Message-Id: <200609221442.07896@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  I have been discussing the packet size s for CCID3 (TFRC) with my
|  supervisor and also been discussing related issues with Gerrit and I
|  am wondering why we have this?
| =20
|  CCID3 is datagram based and the whole point of s is to keep packets at
|  a certain rate per second. In effect provided s is calculated
|  correctly it cancels out of the equation but it becomes more
|  complicated in the code! If it is miscalculated (accidentally or
|  deliberately) it becomes worse because you are either starved or send
|  too much.
| =20
|  Why not just calculate a packet rate per second? Or am I missing
|  something obvious?
I think this is confusing, as it mixes implementation issues with the theor=
y.

Theory:=20
-------
One cannot remove s since it is part of the underlying model. A good explan=
ation
is in [3, chapter 2].  The throughput equation used for TFRC has the form
                  X  =3D  s/RTT *  f(loss_rate)
The `s' originates from the TCP throughput equations where it originally me=
ant=20
maximum segment size (see [1,2]), which relates to the previous two comment=
s.

Practice:
---------
Both CCID 2 and CCID 3 are for fixed packet sizes (cf sections 5.3 of RFC 4=
341/2),=20
i.e. s is a constant and hence you can indeed normalize the equation by div=
iding=20
both sides of the equation by s.

The problem is that an application may be malicious and alter its sending p=
acket
sizes, rfc3448bis suggests to average such changes out. With regard to the =
implemen-
tation, it may be good to use a weighted average of the form such as e.g.:
                  s  =3D  q * len + (1-q) * s
where `len' is either the buffer length at the sender or the size of an inc=
oming
packet at the receiver.=20

Gerrit


References:
-----------
[1]          Mathis, Matthew, Jeffrey Semke, Jamshid Mahdavi and Teunis Ott.
             The Macroscopic Behavior of the Congestion Avoidance Algorithm.
             ACM SIGCOMM Computer Communication Review, 27(3):67--82, 7/199=
7.

[2]          Padhye, J., V. Firoiu, D. Towsley and J. Kurose. Modeling TCP
             Throughput: A Simple Model and its Empirical Validation. ACM
             Computer Communication Review, 28(4):303--314, 1998.
[3]          Widmer, J=F6rg. Equation-Based Congestion Control. Diploma The=
sis,
             University of Mannheim, Germany, 2/2000.
