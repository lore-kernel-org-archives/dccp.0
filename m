From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 01 Oct 2009 20:40:03 +0000
Subject: Re: [PATCH 2/5] Implement loss counting on TFRC-SP receiver
Message-Id: <20091001204003.GA5632@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
In-Reply-To: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| >> The following code would be correct then?
| >>
| >>	 if ((len <=3D 0) ||
| >>	     (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval)))
| > {
| >> +		 cur->li_losses +=3D rh->num_losses;
| >> + 		 rh->num_losses =A0=3D 0;
| >> 		 return false;
| >> With this change I suppose the could be fixed. With that, the
| >> rh->num_losses couldn't added twice. Am I correct?
| >>
| >>
| > The function tfrc_lh_interval_add() is called when
| >  * __two_after_loss() returns true (a new loss is detected) or
| >  * a data packet is ECN-CE marked.
| >
| > I am still not sure about the 'len <=3D 0' case; this would be true
| > if an ECN-marked packet arrives whose sequence number is 'before'
| > the start of the current loss interval, or if a loss is detected
| > which is older than the start of the current loss interval.
| >
| > The other case (tfrc_lh_closed_check) returns 1 if the current loss
| > interval is 'closed' according to RFC 4342, 10.2.
| >
| > Intuitively, in the first case it refers to the preceding loss
| > interval (i.e. not cur->...), in the second case it seems correct.
| >
| > Doing the first case is complicated due to going back in history.
| > The simplest solution I can think of at the moment is to ignore
| > the exception-case of reordered packets and do something like
| >
| >  if (len <=3D 0) {
| >     /* FIXME: this belongs into the previous loss interval */
| >     tfrc_pr_debug("Warning: ignoring loss due to reordering");
| > 	return false;
| > }
| >  if (!tfrc_lh_closed_check(...)) {
| >     // your code from above
| > }
|=20
| Okay, i'll add your sugestion. But i don't know how this would be fixed a=
t all.
|
If it doesn't we will just do another iteration and fix it.



| > So it is necessary to decide whether to go the full way, which means
| >  * support Loss Intervals and Dropped Packets alike
| >  * modify TFRC library (it will be a redesign)
| >  * modify receiver code
| >  * modify sender code,
| >    or to use the present approach where
| >  * the receiver computes the Loss Rate and
| >  * a Mandatory Send Loss Event Rate feature is present during feature
| >    negotiation, to avoid problems with incompatible senders
| >   (there is a comment explaining this, in net/dccp/feat.c).
| >
| > Thoughts?
|=20
<snip>

| I believe that the first way is better (to "support Loss Intervals and
| Dropped Packets alike..."), because RFC requires loss intervals option
| to be sent. And so, proceed and implement dropped packets option for
| TFRC-SP. You are right, this would need a redesign and rewrite of
| sender and receiver code.
|=20
Agree, then let's do that. It requires some coordination on how to arrange
the patches, but we can simplify the process by using the test tree to=20
store all intermediate results (i.e. use a separate tree for the rewrite
until it is sufficiently stable/useful).
