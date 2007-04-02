From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Apr 2007 10:25:20 +0000
Subject: Re: [PATCH 0/25]: CCID3/TFRC updates, net timestamps, TX locking, bug fixes,
Message-Id: <200704021125.20209@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211843.59964@strip-the-willow>
In-Reply-To: <200703211843.59964@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > All patches have been tested for over a month, this particular configu=
ration
|  > has additionally been compile-tested and performance-tested, and uploa=
ded to
|  > =A0 =A0 =A0http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog
|  >
|  >
|  I've reviewed all of these patches now.
| =20
|  Where I didn't give a comment/acked-by/signed-off-by on a patch it's
|  because I haven't understood it fully so said nothing instead.
Many thanks for going through these. Some patches become clearer (a few eve=
n overridden)
by the remaining set of patches. For the record, I list those which have no=
t been acked
below, with small annotations what each patch does and how it fits into the=
 bigger picture.

I would like to submit the others soon, this patch set is not a big thing, =
it mainly prepares
the ground. Also, there is some trouble with the API with regard to half-cl=
osed states; will
send an update soon.


Short summaries (for info)
--------------------------      =20
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/5i_CCID3_No-Burst=
s-Due-To-Idle-Times.diff
 This one goes back to the discussion on accumulating send credits, disallo=
ws large bursts.

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/7b_rfc3448bis_Irr=
elevant-States-Feedback.diff
 This is more of a beautification, overridden later.

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/7d_rfc3448bis_Idl=
e-State-After-NoFeedback-Expiry.diff
 This is one of the later-overridden ones: Actually the idleness/quiescence=
 detection in CCID3 is broken,
 the patch does not change the fact that this is broken. I can remove this =
patch as it is overriden later.

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/7e_rfc3448bis_Use=
-RTO-As-Feedback-Indicator.diff
 This one extends the internal CCID3 state machine by exploiting that t_RTO=
 is not set until the first
 feedback is set - so it can serve as indicator whether _any_ feedback has =
been received so far. Used by
 later patches.

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/7g_rfc3448bis_Upd=
ated-Feedback-Receive.diff
 This creates conformance of the X computation with regard to draft rfc3448=
bis version 01 (the one=20
 in the IETF archives, not the one on Sally Floyd's website). The main poin=
t is that the sending rate
 X is now halved directly when p =3D 0 (this was not clear in the earlier v=
ersion of that draft).

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/7h_rfc3448bis_Upd=
ated-Feedback-Receive.diff
 This continues the previous patch, basically codifying the computation of =
X as presented in draft rfc3448bis,
 version 01. Maybe this is futile since those drafts are a moving target: i=
f we have a clear agreement which
 draft(s) to use, I'd be happy to align all outstanding patches with that. =
So far I had assumed that using
 the latest drafts was ok; in particular since (i) based on some implementa=
tion experience (rather than ns-2),
 (ii) much more clear guidance than just RFC 4342 (which is generic but not=
 specific).


http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/8b_TX-Locking_CCI=
D-3-Initial.diff
 I think that adding TX locking to the lists is necessary for concurrent op=
eration, especially since the
 CCID3 functions can run in different contexts (some are in interrupt, some=
 use process context).=20

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/8c_TX-Locking_CCI=
D-3-Main.diff
 Same comment as above.

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/8d_TX-Locking_Fas=
ter-Purging.diff
 Optimisation of the above.

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/9a_Sockopt_Get-Ma=
x-Packet-Size.diff
 I think this is useful, it is a ``SHOULD'' from [RFC 4340, 14].

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/9e_Option-Parsing=
_Using-Unaligned-Macro-Instead.diff
 This is a real bug fix - one gets these errors eg. on sparc64.

