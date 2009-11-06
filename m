From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 06 Nov 2009 00:05:28 +0000
Subject: Re: Doubt in implementations of mean loss interval at sender side
Message-Id: <cb00fa210911051605w471bc786ia03aa4c0b7371276@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B861.7040107@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B861.7040107@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Wed, Oct 28, 2009 at 12:33 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wro=
te:
> | > This is a good point. Personally, I can not really see an advantage in
> | > storing old data at the sender, as it seems to increase the complexit=
y,
> | > without at the same time introducing a benefit.
> | >
> | > Adding the 'two RTTs old' worth of information at the sender re-intro=
duces
> | > things that were removed already. The old CCID-3 sender used to store
> | > a lot of information about old packets, now it is much leaner and kee=
ps
> | > only the minimum required information.
> |
> | So, how we can solve this? How can we determine if a loss interval is
> | (or not) 2 RTT long in the sender?
> |
> Yes, I also think that this is the core problem.
>
> To be honest, the reply had been receiver-based TFRC in mind but did not
> state the reasons. These are below, which contains also a sketch.
>
> In particular, the 'a lot of information about old packets' mentioned abo=
ve
> could only be taken out (and with improved performance) since it relied on
> using a receiver-based implementation (in fact the code has always been,
> since the original Lulea code).
>
>
> I) (Minimum) set of data required to be stored at the sender
> ------------------------------------------------------------
> RFC 4342, 6 requires a feedback packet to contain
> =A0(a) Elapsed Time or Timestamp Echo;
> =A0(b) Receive Rate option;
> =A0(c) Loss Intervals Option.
>
> Out of these only (b) is currently supported. (a) used to be supported,
> but it turned out that the elapsed time was in the order of circa 50
> microseconds. Timestamp Echo can only be sent if the sender has sent
> a DCCP timestamp option (RFC 4340, 13.3), so it can not be used for the
> general case.
>
> The sender must be able to handle three scenarios:
>
> =A0(a) receiver sends Loss Event Rate option only
> =A0(b) receiver sends Loss Intervals option only
> =A0(c) receiver sends both Loss Event Rate and Loss Intervals option
>
> The implementation currently does (a) and enforces this by using a
> Mandatory Loss Event Rate option (ccid3_dependencies in net/dccp/feat.c),
> resetting the connection if the peer sender only implements (b).
>
> Case (b) is a pre-stage to case (c), otherwise it can only talk to
> DCCP receivers that implement the Loss Intervals option.
>
> In case (c) (and I think this is in part in your implementation), the
> question is what to trust if the options are mutually inconsistent.
> This is the subject of RFC 4342, 9.2, which suggests to store the sending
> times of (dropped) packets.
>
> Window counter timestamps are problematic here, due to the 'increment by =
5'
> rule from RFC 4342, 8.1. Using timestamps raises again the timer-resoluti=
on
> question. If using 10usec from RFC 4342, 13.2 as baseline, the sequence
> number will probably also need to be stored since in 10usec multiple
> packets can be transmitted (also when using a lower resolution).
>
> Until here we have got the requirement to store, for each sent packet,
> =A0* its sending time (min. 4 bytes to match RFC 4342, 13.2)
> =A0* its sequence number (u48 or u64)
> Relating to your question at the top of the email, the next item is
> =A0* the RTT estimate at the time the packet was sent, used for
> =A0 - verifying the length of the Lossy Part (RFC 4342, 6.1);
> =A0 - reducing the sending rate when a Data Dropped option is received, 5=
.2;
> =A0 - determining whether the loss interval was less than or more than 2 =
RTTs
> =A0 =A0 (your question, RFC 4828, 4.4).
>
> To sum up, here is whay I think is minimally required to satisfy the union
> of RFC 4340, 4342, 4828, 5348, and 5622:
>
> =A0 =A0 =A0 =A0struct tfrc_tx_packet_info {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u64 =A0 =A0 seqno:48,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0is_ect0:1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0is_data_packet:1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0is_in_loss_interval:1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 =A0 =A0 send_time;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 =A0 =A0 rtt_estimate;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct tfrc_tx_packet_info *next; /* FIFO =
*/
> =A0 =A0 =A0 =A0};
>
> That would be a per-packet storage cost of about 16 bytes, plus the point=
er
> (8 bytes on 64-bit architectures). One could avoid the pointer by definin=
g a
> =A0 =A0 =A0 =A0u64 =A0 =A0 base_seqno;
> and then
> =A0 =A0 =A0 =A0struct tfrc_tx_packet_info[some constant here];
> and then index the array relative to the base_seqno.
>

Yes, I believe that struct is enough too. But how long would be necessary
the struct array to be?

>
> IIb) Further remarks
> --------------------
> At first sight it would seem that storing the RTT also solves the problem
> of inaccurate RTTs used at the receiver. Unfortunately, this is not the
> case. X_recv is sampled over intervals of varying length which may or may
> not equal the RTT. =A0To factor out the effect of window counters, the se=
nder
> would need to store the packet size as well and would need to use rather
> complicated computations - an ugly workaround.

I didn't understand how the packet size would help and what
computations are needed.

>
> One thing I stumbled across while reading your code was the fact that RFC=
 4342
> leaves it open as to how many Loss Intervals to send: on the one hand it =
follows
> the suggestion of RFC 5348 to use 1+NINTERVAL=3D9, but on the other hand =
it does
> not restrict the number of loss intervals. Also RFC 5622 does not limit t=
he
> number of Loss Intervals / Data Dropped options.
>
> If receiving n > 9 Loss Intervals, what does the sender do with the n-9 o=
lder
> intervals? There must be some mechanism to stop these options from growing
> beyond bounds, so it needs to store also which loss intervals have been
> acknowledged, introducing the "Acknowledgment of Acknowledgments"
> problem.
>

In RFC 4342 section 8.6 it says that the limit of loss interval data
to send is 28, and RFC 5622 8.7 says 84 for dropped packets option.
But I don't see why to send so many data in these options.
Yes, the most recent 9 loss intervals are required to be reported,
except if the sender acknowledged previous sent loss intervals, so in
that case only one is required, the open interval.
And we can avoid the "Acknowledgment of Acknowledgments" if we always send
the required 9 loss intervals, I think.

> A second point is how to compute the loss event rate when n > 9. It seems
> that this would mean grinding through all loss intervals using a window
> of 9. If that is the case, the per-packet-computation costs become very
> expensive.
>

RFC 4342 section 8.6 suggests that only 9 loss intervals are required
anyway. And I believe that's enough for the computation of current
mean loss interval. What do you think?

>
> II) Computational part of the implementation
> --------------------------------------------
> If only Loss Intervals alone are used, only these need to be verified
> before being used to alter the sender behaviour.
>
> But when one or more other DCCP options also appear, the verification is
> =A0* intra: make sure each received option is in itself consistent,
> =A0* inter: make sure options are mutually consistent.
>
> The second has a combinatorial effect, i.e. n! verifications for n option=
s.
>
> For n=3D2 we have Loss Intervals and Dropped Packets: the consistency must
> be in both directions, so we need two stages of verifications.
>
> If Ack Vectors are used in addition to Loss Intervals, then their data
> must also be verified. Here we have up to 6 =3D 3! testing stages.
>
> It gets more complicated (4! =3D 24 checks) by also adding Data Dropped
> options, where RFC 4340, 11.7 requires to check them against the Ack
> Vector, and thus ultimately also against the Loss Intervals option.
>

Yes, there's a combinatorial problem in checking the options for
consistence. But, what if we find out that some option doesn't match
against others? What action would be taken?
First, what can cause the receiver to send inconsistent options? A bad
implementation only?
Accordingly to ecn nonce echo sum algorithm, if a receiver is found to
be lying about loss or to be bad implemented, the sender adjusts the
send rate as if loss were perceived. Can we do the same in this
situation? If so, can we skip
checking options between them and only check ecn nonce sum?
If some option is wrong it show more loss (or any worse situation for
the receiver)
or conceals loss. In the first case, I don't believe we need to care,
and in the second, the ecn nonce sum can reveal the bad acting of the
receiver.

>
> III) Closing remarks in favour of receiver-based implementation
> ---------------------------------------------------------------
> Finally, both RFC 4342 and RFC 5622 do not explicitly discard the
> possibility of using a receiver-based implementation. Quoting
> RFC 4342, 3.2: "If it prefers, the sender can also use a loss event
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rate calculated and reported by the receiv=
er."
> Furthermore, the revised TFRC specification points out in section 7
> the advantages that a receiver-based implementation has:
> =A0* it does not mandate reliable delivery of packet loss data;
> =A0* it is robust against the loss of feedback packets;
> =A0* better suited for scalable server design.
>
> Quite likely, if the server does not have to store and validate a mass
> of data, it is also less prone to be toppled by DoS attacks.
>

You're right. But what the RFC's says about it is almost exactly the
opposite, isn't? What can we do about it? I like the receiver-based design,
but I believe that loss intervals are interesting, mostly because=A0 of
receiver behavior verification.

> | > As a second point, I still think that a receiver-based CCID-4 impleme=
ntation
> | > would be the simplest possible starting point. In this light, do you =
see an
> | > advantage in supplying an RTT estimate from sender to receiver?
> |
> | Yes, better precision. But, at the cost of adding an option
> | undocumented by any RFC's?
> |
> No I wasn't suggesting that. As you rightly point out, the draft has
> expired. It would need to be overhauled (all the references have
> changed, but the problem has not), and I was asking whether returning
> to this has any benefit.
>
> The text is the equivalent of a bug report. RFCs are like software - if no
> one submits bug reports, they become features, until someone has enough of
> such 'features' and writes a new specification.


--
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Putt's Law:
=A0 =A0 =A0 Technology is dominated by two types of people:
=A0 =A0 =A0 =A0 =A0 =A0 =A0 Those who understand what they do not manage.
=A0 =A0 =A0 =A0 =A0 =A0 =A0 Those who manage what they do not understand.
