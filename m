From: gerrit@erg.abdn.ac.uk
Date: Sat, 19 Sep 2009 12:11:19 +0000
Subject: Re: [PATCH 2/5] Implement loss counting on TFRC-SP receiver
Message-Id: <5001.72.11.80.242.1253362279.squirrel@72.11.80.242>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
In-Reply-To: <cb00fa210909011944r60f310bcx7e3f45e619f41498@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s64 len =3D dccp_delta_seqno(cur->li_seqn=
o,
>> cong_evt_seqno);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((len <=3D 0) ||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(!tfrc_lh_closed_check(cur,
>> cong_evt->tfrchrx_ccval))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur->li_losses +=3D rh->nu=
m_losses;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> This has a multiplicative effect, since rh->num_losses is added to
cur->li_losses
>> each time the condition is evaluated. E.g. if 3 times in a row
reordered
>> (earlier)
>> sequence numbers arrive, or if the CCvals do not differ (high-speed
networks),
>> we end up with 3 * rh->num_losses, which can't be correct.
>
>
> The following code would be correct then?
>
>               if ((len <=3D 0) ||
>                   (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval)))
{
> +                       cur->li_losses +=3D rh->num_losses;
> +                       rh->num_losses  =3D 0;
>                       return false;
> With this change I suppose the could be fixed. With that, the
> rh->num_losses couldn't added twice. Am I correct?
>
>
The function tfrc_lh_interval_add() is called when
 * __two_after_loss() returns true (a new loss is detected) or
 * a data packet is ECN-CE marked.

I am still not sure about the 'len <=3D 0' case; this would be true
if an ECN-marked packet arrives whose sequence number is 'before'
the start of the current loss interval, or if a loss is detected
which is older than the start of the current loss interval.

The other case (tfrc_lh_closed_check) returns 1 if the current loss
interval is 'closed' according to RFC 4342, 10.2.

Intuitively, in the first case it refers to the preceding loss
interval (i.e. not cur->...), in the second case it seems correct.

Doing the first case is complicated due to going back in history.
The simplest solution I can think of at the moment is to ignore
the exception-case of reordered packets and do something like

    if (len <=3D 0) {
       /* FIXME: this belongs into the previous loss interval */ =20
tfrc_pr_debug("Warning: ignoring loss due to reordering");
       return false;
    }
    if (!tfrc_lh_closed_check(...)) {
        // your code from above
    }

However, there is a much deeper underlying question: currently the
implementation is not really what the specification says; if we
wanted to abide by the letter of the law, we would have to implement
the Loss Intervals Option first, and then sort out such details as
above. Discussion continues further below.

>> --- dccp_tree_work4.orig/net/dccp/ccids/lib/packet_history_sp.c +++
dccp_tree_work4/net/dccp/ccids/lib/packet_history_sp.c
>> @@ -244,6 +244,7 @@
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0h->loss_count =3D 3;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hi=
st_entry(h, 3),
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 skb, n3);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 h->num_losses =3D dccp_loss_count(s2, s3, =
n3);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
>> =A0 =A0 =A0 =A0}
>> This only measures the gap between s2 and s3, but the "hole" starts at s=
0,
>> so it would need to be dccp_loss_count(s0, s3, n3). Algorithm is
documented at
>> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/\
>> ccid3/ccid3_packet_reception/loss_detection/loss_detection_algorithm_not=
es.txt
>
> <snip>
>
>> =A0}
>> Here it is also between s0 and s2, not between s0 and s3. It is case
VI(c.3).
>> However, the above still is a crude approximation, since it only
measures between
>> the last sequence number received before the loss and the third
sequence
>> number
>> after the loss. It would be better to either
>> =A0* use the first sequence number after the loss (this can be s1, s2, or
s3) or
>> =A0* check if there are more holes between the first/second and the
second/third
>> =A0 sequence numbers after the loss.
>> The second option would be the correct one, it should also take the NDP
counts
>> of each gap into account. And already we have a fairly complicated
algorithm.
>
>
>
> I'll study loss_detection_algorithm_notes.txt and correct the code. But
I have one question, that i don't know if is already answered by the
documentation:
> Further holes, between the the first and third packet received after the
hole are accounted only in future calls to the function, right? Because
the receiver needs to receive more packets to confirm loss, right?
> So, it's really necessary to look for other holes after the loss? Will
not this other holes be identified as losses in future?
I stand corrected, you are right: only the hole between
 * the highest sequence number before the loss (S0) and
 * the first sequence number after the loss
   (S1 or S3 depending on reordering)
are relevant.

Continuing the point from above, I would like to ask which way you would
like to go with your implementation:
 (a) receiver computes the Loss Event Rate, sender just uses this value
 (b) receiver only gathers the data (loss intervals, lost packets),
     sender does all the verification, book-keeping, and computation.

From reading your patches, I think it is going in the direction of (a).
But if this is the case, we don't need the Dropped Packets Option from
RFC 5622, 8.7. By definition it only makes sense if Loss Intervals
Options are also present.

So it is necessary to decide whether to go the full way, which means
 * support Loss Intervals and Dropped Packets alike
 * modify TFRC library (it will be a redesign)
 * modify receiver code
 * modify sender code,
or to use the present approach where
 * the receiver computes the Loss Rate and
 * a Mandatory Send Loss Event Rate feature is present during feature
   negotiation, to avoid problems with incompatible senders
   (there is a comment explaining this, in net/dccp/feat.c).

Thoughts?

