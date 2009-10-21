From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 21 Oct 2009 13:18:23 +0000
Subject: Re: Doubt in implementations of mean loss interval at sender side
Message-Id: <cb00fa210910210618g5f079096sfb75bee99f595f01@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B861.7040107@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B861.7040107@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Tue, Oct 20, 2009 at 2:09 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrot=
e:
> | It considers if an interval is 2 RTT old, instead of 2 RTT long. But I
> | sent this code in this state anyway, because I want to ask how to solve
> | this problem.
> This is a good point. Personally, I can not really see an advantage in
> storing old data at the sender, as it seems to increase the complexity,
> without at the same time introducing a benefit.
>
> Adding the 'two RTTs old' worth of information at the sender re-introduces
> things that were removed already. The old CCID-3 sender used to store
> a lot of information about old packets, now it is much leaner and keeps
> only the minimum required information.

So, how we can solve this? How can we determine if a loss interval is
(or not) 2 RTT long in the sender?

> Your receiver already implements '2 RTTs long':
> tfrc_sp_lh_interval_add():
>
> =A0 =A0 =A0 =A0/* Test if this event starts a new loss interval */
> =A0 =A0 =A0 =A0if (cur !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s64 len =3D dccp_delta_seqno(cur->li_seqno=
, cong_evt_seqno);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// ...
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cur->li_length =3D len;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (SUB16(cong_evt->tfrchrx_ccval, cur->li=
_ccval) <=3D 8)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cur->li_is_short =3D 1;
> =A0 =A0 =A0 =A0}
>
> Would it help your implementation if the receiver had a more precise meas=
ure
> for "2 RTT long"? A while ago I got fed up with the imprecise RTT measure=
ments
> that the receiver produced when using the CCVal to compute the RTT. The
> suggestion was that the sender would supply its RTT estimate via an optio=
n,
>
> =A0 =A0"Sender RTT Estimate Option for DCCP"
> =A0 =A0http://tools.ietf.org/html/draft-renker-dccp-tfrc-rtt-option-00
>
> If the receiver knew the RTT, it could subtract timestamps and compare
> these against the RTT value. Currently, with the CCVal it is (as for
> the receiver-based RTT estimation), a bit difficult. RFC 5622, 8.1:
>
> =A0"None of these procedures require the receiver to maintain an explicit
> =A0estimate of the round-trip time. However, Section 8.1 of [RFC4342]
> =A0gives a procedure that implementors may use if they wish to keep such
> =A0an RTT estimate using CCVal."
>
> But the problem is that the algorithm in section 8.1 of RFC 4342 (which
> is used by the CCID-3/4 receiver has already proven not to be very reliab=
le,
> it suffers from similar problems as the packet-pair technique.
>

This would be an improvement over the current RTT determination method
on the receiver. But it wouldn't help the sender problem that I said
above. There is no way in Loss Intervals option to tell the sender
about the duration of each Loss Interval, I think.

> As a second point, I still think that a receiver-based CCID-4 implementat=
ion
> would be the simplest possible starting point. In this light, do you see =
an
> advantage in supplying an RTT estimate from sender to receiver?

Yes, better precision. But, at the cost of adding an option
undocumented by any RFC's?


--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
