From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 20 Jun 2007 09:35:56 +0000
Subject: Re: [PATCH 5/5]: Implement rfc3448bis changes to feedback reception
Message-Id: <200706201035.56775@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706111539.48754@strip-the-willow>
In-Reply-To: <200706111539.48754@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > Note: At some point of time this probably needs update wrt rfc3448bis,=
 but see
|  > =A0 =A0 =A0 http://www.mail-archive.com/dccp%40ietf.org/msg00426.html
|  >
| =20
|  I agree that sending rate calculation, particularly after idle still
|  needs work - but this is at the =A0IETF level and this helps a lot by
|  the looks.
Fully agree with that point and this should be revised as soon as there is =
some
stabilisation in the specification. Out of my head, the following things mo=
re or
less directly depend on this:

 * Oscillation Prevention from RFC 3448 / rfc3448bis
   - affects also `congestion control on LANs' (a point you raised)
   - with the RTTs measured on layer 4, this would be useful
     since when sending `blasts' of packets, the queue buildup is quickly p=
erceivable

 * Faster Restart

 * the CCID 3 definition of idle times - RFC 4342 (6.4) uses the max(0.2 se=
c, 2*RTT)

 * ... other areas depending on the calculation I may have missed
     =20
