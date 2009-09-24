From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Thu, 24 Sep 2009 01:43:18 +0000
Subject: Re: [PATCH 2/5] Implement loss counting on TFRC-SP receiver
Message-Id: <cb00fa210909231843q7f13b2c3i32672e883a017b7b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
In-Reply-To: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Sat, Sep 19, 2009 at 9:11 AM, =A0<gerrit@erg.abdn.ac.uk> wrote:
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s64 len =3D dccp_delta_seqno(cur->li_seq=
no,
>>> cong_evt_seqno);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((len <=3D 0) ||
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(!tfrc_lh_closed_check(cur,
>>> cong_evt->tfrchrx_ccval))) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur->li_losses +=3D rh->n=
um_losses;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>> This has a multiplicative effect, since rh->num_losses is added to
> cur->li_losses
>>> each time the condition is evaluated. E.g. if 3 times in a row
> reordered
>>> (earlier)
>>> sequence numbers arrive, or if the CCvals do not differ (high-speed
> networks),
>>> we end up with 3 * rh->num_losses, which can't be correct.
>>
>>
>> The following code would be correct then?
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((len <=3D 0) ||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (!tfrc_lh_closed_check(cur, cong_evt=
->tfrchrx_ccval)))
> {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur->li_losses +=3D rh->nu=
m_losses;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rh->num_losses =A0=3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
>> With this change I suppose the could be fixed. With that, the
>> rh->num_losses couldn't added twice. Am I correct?
>>
>>
> The function tfrc_lh_interval_add() is called when
> =A0* __two_after_loss() returns true (a new loss is detected) or
> =A0* a data packet is ECN-CE marked.
>
> I am still not sure about the 'len <=3D 0' case; this would be true
> if an ECN-marked packet arrives whose sequence number is 'before'
> the start of the current loss interval, or if a loss is detected
> which is older than the start of the current loss interval.
>
> The other case (tfrc_lh_closed_check) returns 1 if the current loss
> interval is 'closed' according to RFC 4342, 10.2.
>
> Intuitively, in the first case it refers to the preceding loss
> interval (i.e. not cur->...), in the second case it seems correct.
>
> Doing the first case is complicated due to going back in history.
> The simplest solution I can think of at the moment is to ignore
> the exception-case of reordered packets and do something like
>
> =A0 =A0if (len <=3D 0) {
> =A0 =A0 =A0 /* FIXME: this belongs into the previous loss interval */
> tfrc_pr_debug("Warning: ignoring loss due to reordering");
> =A0 =A0 =A0 return false;
> =A0 =A0}
> =A0 =A0if (!tfrc_lh_closed_check(...)) {
> =A0 =A0 =A0 =A0// your code from above
> =A0 =A0}

Okay, i'll add your sugestion. But i don't know how this would be fixed at =
all.

>
> However, there is a much deeper underlying question: currently the
> implementation is not really what the specification says; if we
> wanted to abide by the letter of the law, we would have to implement
> the Loss Intervals Option first, and then sort out such details as
> above. Discussion continues further below.
>

Yes, the loss intervals options is mandatory. I'll discuss this too below.

>>> --- dccp_tree_work4.orig/net/dccp/ccids/lib/packet_history_sp.c +++
> dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.c
>>> @@ -244,6 +244,7 @@
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0h->loss_count =3D 3;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_h=
ist_entry(h, 3),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 skb, n3);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->num_losses =3D dccp_loss_count(s2, s3,=
 n3);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
>>> =A0 =A0 =A0 =A0}
>>> This only measures the gap between s2 and s3, but the "hole" starts at =
s0,
>>> so it would need to be dccp_loss_count(s0, s3, n3). Algorithm is
> documented at
>>> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/\
>>> ccid3/ccid3_packet_reception/loss_detection/loss_detection_algorithm_no=
tes.txt
>>
>> <snip>
>>
>>> =A0}
>>> Here it is also between s0 and s2, not between s0 and s3. It is case
> VI(c.3).
>>> However, the above still is a crude approximation, since it only
> measures between
>>> the last sequence number received before the loss and the third
> sequence
>>> number
>>> after the loss. It would be better to either
>>> =A0* use the first sequence number after the loss (this can be s1, s2, =
or
> s3) or
>>> =A0* check if there are more holes between the first/second and the
> second/third
>>> =A0 sequence numbers after the loss.
>>> The second option would be the correct one, it should also take the NDP
> counts
>>> of each gap into account. And already we have a fairly complicated
> algorithm.
>>
>>
>>
>> I'll study loss_detection_algorithm_notes.txt and correct the code. But
> I have one question, that i don't know if is already answered by the
> documentation:
>> Further holes, between the the first and third packet received after the
> hole are accounted only in future calls to the function, right? Because
> the receiver needs to receive more packets to confirm loss, right?
>> So, it's really necessary to look for other holes after the loss? Will
> not this other holes be identified as losses in future?
> I stand corrected, you are right: only the hole between
> =A0* the highest sequence number before the loss (S0) and
> =A0* the first sequence number after the loss
> =A0 (S1 or S3 depending on reordering)
> are relevant.

Thanks, already corrected in next patch.

>
> Continuing the point from above, I would like to ask which way you would
> like to go with your implementation:
> =A0(a) receiver computes the Loss Event Rate, sender just uses this value
> =A0(b) receiver only gathers the data (loss intervals, lost packets),
> =A0 =A0 sender does all the verification, book-keeping, and computation.
>
> From reading your patches, I think it is going in the direction of (a).
> But if this is the case, we don't need the Dropped Packets Option from
> RFC 5622, 8.7. By definition it only makes sense if Loss Intervals
> Options are also present.
>
> So it is necessary to decide whether to go the full way, which means
> =A0* support Loss Intervals and Dropped Packets alike
> =A0* modify TFRC library (it will be a redesign)
> =A0* modify receiver code
> =A0* modify sender code,
> or to use the present approach where
> =A0* the receiver computes the Loss Rate and
> =A0* a Mandatory Send Loss Event Rate feature is present during feature
> =A0 negotiation, to avoid problems with incompatible senders
> =A0 (there is a comment explaining this, in net/dccp/feat.c).
>
> Thoughts?
>

Initially I conceived that the receiver would compute the loss event
rate and send it, along with loss intervals and dropped packets
option. And this would enable the sender to just use the loss event
rate reported, as is done currently (in current implementation of
TFRC), or compute it itself, using loss intervals option (in case of
CCID3) and dropped packets option too (CCID4's case).
In my code, I compute the loss event rate using the options, then
compare the two values. I don't know if would be better to keep all
the loss event rate calc only at one side, sender or receiver.

I believe that the first way is better (to "support Loss Intervals and
Dropped Packets alike..."), because RFC requires loss intervals option
to be sent. And so, proceed and implement dropped packets option for
TFRC-SP. You are right, this would need a redesign and rewrite of
sender and receiver code.




--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
