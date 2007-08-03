From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 03 Aug 2007 14:14:16 +0000
Subject: Re: relating code to RFC 4342, RFC 3448, rfc3448bis-00
Message-Id: <200708031514.16519@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Ian,

below is as promised the list of differences of the CCID3 code, this has th=
e most relevant differences.

The list may not be exhaustive, but this is all I can get hold of for the m=
oment.

Most is also documented online at
      http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_recept=
ion/



1. General
----------
The code conforms to RFC 4342 as far as possible. Where deviating, the chan=
ges introduced
in draft rfc3448bis, revision 00, are used as reference.

2. TFRC code
-------------
* loss detection is fully compliant with RFC 4342, including the handling o=
f DUPACKS

* details on=20
  http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/=
loss_detection/loss_detection_algorithm_notes.txt=20

* receiver RTT sampling uses a modified algorithm from RFC 4342, 8.1. This =
is an extension
  (uses all data it can get), but the principle is the algorithm from RFC 4=
342.

* the loss interval handling uses rfc3448bis rather than RFC 3448, due to t=
he following
  limitation of RFC 3448:=20
	RFC 3448 considers only a fixed set of n=3D8 loss intervals. It takes quit=
e a while
        until that many loss intervals have accumulated. rfc3448bis is bett=
er in this regard,
        since it specifies handling up to k < n =3D 8 loss intervals. This =
is more realistic=20
        and hence has been adapted for the code.    =20

* the weights used for the individual loss intervals use the precise, not t=
he mod-2 rounded
  values, from RFC 3448, section 5.4 rather than section 8. This is because=
 it gives a better
  performance and since there is no real gain in using shift operations her=
e.

* lost packets are always assumed to be data packets (cf. section 7 of the =
above URL for clarification)

* updating I_mean, in contrast, is based on section 10.2 of RFC 4342 rather=
 than RFC 3448/rfc3448bis.
  RFC 4342 introduced a method to find out where a new loss interval starts=
, with respect to sequence
  number wrap-around (field li_is_closed).

* similarly, determining whether a newly identified loss event does indeed =
designate a new loss=20
  interval depends is based on RFC 4342, 10.2 rather than RFC 3448/rfc3448b=
is


3. CCID3 code
--------------
* RFC3390 initial rate uses `s' instead of MSS described in RFC 4342, as pe=
r previous discussion

* all non-RFC 4342 based code uses revision 00 of draft rfc3448bis as basis=
, in particular:
	- computation procedures in ccid3_hc_tx_update_x(),
	- updating X when feedback is received in ccid3_hc_tx_packet_recv(),
	- updating X in ccid3_hc_tx_no_feedback_timer(),

* TX CCID3 uses RTT from Request/Response handshake - as per RFC 4342 errat=
um.

* packet scheduling closely follows section 4.6 of RFC 3448. Still not sure=
 that this is the best
  way to do this, but recent tests (cf. bug reports and dropping of `send c=
redit' patch) showed that
  apparently this works quite satisfactorily.

* the value of `s' is not fixed but uses EWMA - something which rfc3448bis =
clarified and introduced.

* computing X_recv uses a disambiguation which tries to reconcile between t=
he different definitions
  of RFC 3448 and 4342, cf.=20
  http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/=
#8._Computing_X_recv_

* introduced the possibility of changing the t_nfb to avoid frequently call=
ing the no_feedback_timer
  when the RTT is small (Kconfig option)

* CCID3 packet reception (RX CCID) is largely conformant with RFC 3448/rfc3=
448bis rev 00 and was a
  pain to get right. See http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/=
ccid3_packet_reception why.

* sending feedback is also largely conformant with RFC 4342/3448, with the =
addition of the clarification
  for computing X_recv when the time interval between sending the last feed=
back and now is less than one
  RTT - in this case the previously computed X_recv value is reused (would =
otherwise lead to false=20
  estimates of X_recv).

HTH
Gerrit

|  > | =A0If you do have a list of them it would be great. I see quite a few
|  > | =A0comments about bis in the code.
|  > I don't have a list at present, need to go through the works. Will pos=
t at a later point.
|  >
|  Don't worry too much about this, as this is my research so don't want
|  to waste your time :-)
