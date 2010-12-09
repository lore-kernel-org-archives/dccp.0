From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Thu, 09 Dec 2010 14:54:41 +0000
Subject: Fwd: DCCP - sysctl sequence window
Message-Id: <AANLkTi=7_NFXUQuE0hOt+2tK-ZY2bRsc2mN0iCCdY709@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Forwarding to the DCCP mailing list

---------- Forwarded message ----------
From: Husz=E1k =C1rp=E1d <huszak@hit.bme.hu>
Date: 8 December 2010 13:39
Subject: DCCP - sysctl sequence window
To: acme@mandriva.com, acme@conectiva.com.br, ian.mcdonald@jandi.co.nz


Dear Arnaldo and Ian,

According to RFC4340 "The maximum valid Sequence Window value is Wmax 2^46 =
- 1 =3D 70368744177663", however I could set the sequence window size
to this value using linux kernel 2.6.36.
I tried to do this with the command:
sudo sysctl -w net.dccp.default.seq_windowp368744177663
and also by modifying /proc/sys/net/dccp/default/seq_window file.

The maximum value of the seq_window I could set was 2^32-1 (4294967295).

I found the reason of this malfunction in feat.h:
106 extern unsigned long sysctl_dccp_sequence_window;

and feat.c:
30 unsigned long =A0 sysctl_dccp_sequence_window __read_mostly =3D 100;

The maximum of an unsigned long variable is 2^32-1 (4294967295).

Best regards,
Arpad


--
---------------------------------------------------------------------
=C1rp=E1d HUSZ=C1K, Ph.D.
assistant professor =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0Tel: +36 1 =A0463-2076
Budapest University of Technology and Economics =A0 =A0 =A0 +36 70 514-5925
Department of Telecommunications, I.E.432 =A0 =A0 =A0www.hit.bme.hu/~huszak
---------------------------------------------------------------------
