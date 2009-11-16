From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Mon, 16 Nov 2009 20:09:42 +0000
Subject: Re: Doubt in implementations of mean loss interval at sender side
Message-Id: <cb00fa210911161209v384f883chd1b821ca40dde06a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B861.7040107@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B861.7040107@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, Nov 9, 2009 at 4:09 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> | > To sum up, here is whay I think is minimally required to satisfy the =
union
> | > of RFC 4340, 4342, 4828, 5348, and 5622:
> | >
> | > =A0 =A0 =A0 =A0struct tfrc_tx_packet_info {
> | > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u64 =A0 =A0 seqno:48,
> | > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0is_ect0:1,
> | > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0is_data_packet:1,
> | > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0is_in_loss_interval:1;
> | > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 =A0 =A0 send_time;
> | > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 =A0 =A0 rtt_estimate;
> | > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct tfrc_tx_packet_info *next; /* F=
IFO */
> | > =A0 =A0 =A0 =A0};
> | >
> | > That would be a per-packet storage cost of about 16 bytes, plus the p=
ointer
> | > (8 bytes on 64-bit architectures). One could avoid the pointer by def=
ining a
> | > =A0 =A0 =A0 =A0u64 =A0 =A0 base_seqno;
> | > and then
> | > =A0 =A0 =A0 =A0struct tfrc_tx_packet_info[some constant here];
> | > and then index the array relative to the base_seqno.
> | >
> |
> | Yes, I believe that struct is enough too. But how long would be necessa=
ry
> | the struct array to be?
> |
> The problem is the same as with Ack Vectors - the array (or list) can grow
> arbitrarily large. You made a good reply, since all the questions are
> inter-related. The first two I see here are
>
> =A01) the choice of data structure (array or list)
> =A02) the design of a garbage-collector
>
> This includes your point from above, about the maximum size. To draw the
> analogy to Ack Vectors, at the moment they use a fixed size. On certain
> mediums (WiFi) there exist situations where even that fixed limit is
> reached, causing an overflow with Ack Vectors that have reached a size
> of 2 * 253 =3D 506 bytes.
>
> Looking after old data of sent packets is similar, the main difference I
> see that at some stage "unused" old entries need to be collected, to avoid
> the overflow problem which occurs when using a fixed-size structure.
>
> I find that 'Acknowledgments of Acknowledgments' is a bad idea, since it
> means implementing reliable delivery over unreliable transport; on the
> one hand DCCP is designed to be unreliable, but here suddenly is a break
> with that design decision.
>
> So point (2) will probably mean coming up with some guessed heuristics
> that will work for most scenarios, but may fail in others.
>
>
> This is why I am not a big fan of the sender-based solution: to solve (2)=
 and
> your question from above requires a lot of testing of the garbage-collect=
ion
> and book-keeping algorithms, rather than on the actual congestion control.
>
> One can spend a lot of time going over these issues, but of what use is t=
he
> most ingenious data structure if the overall protocol behavior does not
> deliver a useful performance to users of the protocol?

Yes, a sender-based implementation seems really complicated, mainly in
principle.

>
> | > IIb) Further remarks
> | > --------------------
> | > At first sight it would seem that storing the RTT also solves the pro=
blem
> | > of inaccurate RTTs used at the receiver. Unfortunately, this is not t=
he
> | > case. X_recv is sampled over intervals of varying length which may or=
 may
> | > not equal the RTT. =A0To factor out the effect of window counters, th=
e sender
> | > would need to store the packet size as well and would need to use rat=
her
> | > complicated computations - an ugly workaround.
> |
> | I didn't understand how the packet size would help and what
> | computations are needed.
> |
> The above still refers to the earlier posting about letting the sender
> supply the RTT estimate R_i in packet `i' as defined in RFC 5348, 3.2.1.
>
> Though the same section later suggests that a coarse-grained timestamp
> is sufficient, in practice the inaccuracy of the RTT means inaccurate
> X_recv, and as a consequence sub-optimal protocol performance.
>
> The problem is that the algorithm from RFC 4342, 8.1 assumes that the
> rate of change of the window counter also relates to the change of
> packet spacing (the difference between the T_i packe arrivel times).
>
> Howver, especially when using high-speed (1/10 Gbit) networking, this
> assumption often does not hold in practice. Packets are sent by the netwo=
rk
> card in bunches, or intervening switches/routers cause a compression of
> packet inter-arrival times. Hence it is perfectly possible that a bundle =
of
> packets with different Window Counter CCVal values arrive at virtually
> the same time. For instance, on a 100Mbs ethernet I have seen spikes of
> X_recv of up to 2-3 Gbits/sec. Several orders of magnitude from the
> real packet speed (not to mention the unrealistic value).
>
> So the question above was asking whether there is a way for the sender
> to "compute away" the inaccuracies reported by the receiver. Your reply
> confirms my doubts that doing this is probably not possible.
>
> To clarify, I was asking whether it would be possible for the sender to
> perform step (2) of RFC 5348, 6.2; to compensate for the fact that the
> receiver does not have a reliable RTT estimate.

I understand now the issue, thanks. Isn't better to just send the RTT estim=
ate
to the sender, as the RFC says?

>
> For example, when receiving feedback for packet `i', it would iterate
> through the list/array, going back over as many packets as are covered
> by the send time T_i of packet `i' minus the RTT estimate R_i at that
> time, sum their packet sizes, and from that value recompute X_recv.
>
> This is a bit complicated if the garbage-collector has already purged
> older entries, so part of the garbage collector would probably have
> to watch over acknowledged packets. I add this as item
> =A03) validate X_recv
> to the above running list of book-keeping items done at the sender.
>
>
> | > One thing I stumbled across while reading your code was the fact that=
 RFC 4342
> | > leaves it open as to how many Loss Intervals to send: on the one hand=
 it follows
> | > the suggestion of RFC 5348 to use 1+NINTERVAL=3D9, but on the other h=
and it does
> | > not restrict the number of loss intervals. Also RFC 5622 does not lim=
it the
> | > number of Loss Intervals / Data Dropped options.
> | >
> | > If receiving n > 9 Loss Intervals, what does the sender do with the n=
-9 older
> | > intervals? There must be some mechanism to stop these options from gr=
owing
> | > beyond bounds, so it needs to store also which loss intervals have be=
en
> | > acknowledged, introducing the "Acknowledgment of Acknowledgments"
> | > problem.
> |
> | In RFC 4342 section 8.6 it says that the limit of loss interval data
> | to send is 28, and RFC 5622 8.7 says 84 for dropped packets option.
> | But I don't see why to send so many data in these options.
> | Yes, the most recent 9 loss intervals are required to be reported,
> | except if the sender acknowledged previous sent loss intervals, so in
> | that case only one is required, the open interval.
> | And we can avoid the "Acknowledgment of Acknowledgments" if we always s=
end
> | the required 9 loss intervals, I think.
> |
> | > A second point is how to compute the loss event rate when n > 9. It s=
eems
> | > that this would mean grinding through all loss intervals using a wind=
ow
> | > of 9. If that is the case, the per-packet-computation costs become ve=
ry
> | > expensive.
> |
> | RFC 4342 section 8.6 suggests that only 9 loss intervals are required
> | anyway. And I believe that's enough for the computation of current
> | mean loss interval. What do you think?
> |
> Yes, absolutely, I am completely in favour of this very sensible suggesti=
on.
>
> If people really must experiment with such outdated data, that could be
> done in truly experimental patches. Especially since RFC 5348 normatively
> recommends a value of n =3D 8 in section 5.4. And we are saving further
> headaches about the book-keeping/garbage collection of old data.
>
> | > II) Computational part of the implementation
> | > --------------------------------------------
> | > If only Loss Intervals alone are used, only these need to be verified
> | > before being used to alter the sender behaviour.
> | >
> | > But when one or more other DCCP options also appear, the verification=
 is
> | > =A0* intra: make sure each received option is in itself consistent,
> | > =A0* inter: make sure options are mutually consistent.
> | >
> | > The second has a combinatorial effect, i.e. n! verifications for n op=
tions.
> | >
> <snip>
> |
> | Yes, there's a combinatorial problem in checking the options for consis=
tence.
> | But, what if we find out that some option doesn't match against others?
> | What action would be taken?
> I add this as
> =A04) define policy for dealing with options that are not mutually consis=
tent
>
> | First, what can cause the receiver to send inconsistent options?
> | A bad implementation only?
> Yes I think that a bad implementation (whether on purpose or not) would be
> the main cause, since header options are protected even if partial
> checksums are used (RFC 4340, 9.2).
>
> But there is also the benign case mentioned at the end of RFC 4342, 9.2,
> where a receiver collapses multiple losses into a single loss event, i.e.
> =A05) validate received Loss Intervals and regroup the receiver-based
> =A0 =A0information if necessary, without interpreting this as attempted
> =A0 =A0receiver misbehaviour.
>
> | Accordingly to ecn nonce echo sum algorithm, if a receiver is found to =
be
> | lying about loss or to be bad implemented, the sender adjusts the send =
rate
> | as if loss were perceived.
> | Can we do the same in this situation? If so, can we skip checking optio=
ns
> | between them and only check ecn nonce sum?
> This is difficult since Ack Vectors and Loss Intervals use different
> definitions of ECN Nonce sum (last paragraph in RFC 4342, 9.1), i.e. we h=
ave
> =A06) separate algorithms to compute Ack Vector/Loss Intervals ECN Nonce =
sum.
>
> With regard to (5) above, your suggestion gives
> =A07) validate options, on mismatch other than (5) only validate ECN nonc=
e.
>
> | If some option is wrong it show more loss (or any worse situation for t=
he
> | receiver) or conceals loss. In the first case, I don't believe we need =
to care,
> | and in the second, the ecn nonce sum can reveal the bad acting of the r=
eceiver.
> Yes you are right, we need not worry if a receiver reports a higher loss =
rate
> than the verification done by the sender (which recomputes the data that =
the
> receiver already has computed) calculates.
>
> But for the second case, there is no guarantee to catch a misbehaving
> receiver, only a 50% chance at the end of many computations.

Isn't it 50% chance at each ecn verified? So, at the end we'll end up with =
100%?

>
> RFC 4342, 9 suggests one way of verifying Loss Intervals / Ack Vectors:
> =A05) occasionally do not send a packet, or send packet out of order.
>
> This increases complexity of book-keeping, the sender needs to keep track
> which of the sent packets was a fake send/drop. It also requires an algor=
ithm
> to iterate over the sender data structures in order to find out whether t=
he
> reasoning of the receiver is sane. I have doubts whether this can be done
> without sacrificing the performance of the in-kernel sender side.
>

I have doubts either. This seems to be too complicated and not much useful.

>
> | > III) Closing remarks in favour of receiver-based implementation
> | > ---------------------------------------------------------------
> | > Finally, both RFC 4342 and RFC 5622 do not explicitly discard the
> | > possibility of using a receiver-based implementation. Quoting
> | > RFC 4342, 3.2: "If it prefers, the sender can also use a loss event
> | > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rate calculated and reported by the re=
ceiver."
> | > Furthermore, the revised TFRC specification points out in section 7
> | > the advantages that a receiver-based implementation has:
> | > =A0* it does not mandate reliable delivery of packet loss data;
> | > =A0* it is robust against the loss of feedback packets;
> | > =A0* better suited for scalable server design.
> | >
> | > Quite likely, if the server does not have to store and validate a mass
> | > of data, it is also less prone to be toppled by DoS attacks.
> |
> | You're right. But what the RFC's says about it is almost exactly the
> | opposite, isn't? What can we do about it? I like the receiver-based des=
ign,
> | but I believe that loss intervals are interesting, mostly because =A0of
> | receiver behavior verification.
> |
> While writing the above reply, I was amazed to see how much of the comput=
ation
> that has already been done at the receiver needs to be done again at the =
sender,
> ust in order to be able to verify the data.
>
> To me this seems very inefficient.
>
> Moreover, the biggest danger I see here is spending a lot of time with the
> details of sender book-keeping and verification, just to then see that the
> performance of CCID-3/4 in practice turns out to be below the standards
> acceptable to even modest users.
>
> I think it is clearly better to prefer the simplest possible implementati=
on
> in such cases, to better debug live protocol performance.
>
> In particular, since CCID-4 is designed to be an experimental protocol
> (i.e. if it works, RFC 5622 may mature into a Proposed Standard, if not,
> it might be superseded by a different specification).
>
> And I think that testing the actual user performance has the highest prio=
rity.

Yes, we can work more with a simpler implementation at the receiver
side and focus
on performance and test, and features too. After, we have a stable
version and good enough in performance terms,
=A0we can continue improving the sender side.

>
> The literature on the subject is almost exclusively done on experiences in
> ns-2 userland. Almost no Internet experiments at all have been done with =
DCCP.
>
> This is because the IPPROTO =3D 33 identifier needs to be entered
> especially into a firewall, which opens holes that firewall
> administrators don't like to open (unless the firewall is based on
> a recent Linux kernel, opening all ports for IP protocol identifier
> 33 is the only way of allowing DCCP traffic in/out of a firewall).
>
> In addition, most people use NAT at home, putting another obstacle
> on experiments. The result is then that tests are done in a lab testbed
> or in virtualisation - emulated networks.
>
> To conclude, I still think that the simpler, receiver-based implementation
> gives a better start. A 'perfect' receiver implementation is also a good
> reference point to start protocol evaluation: if the performance is bad
> despite getting things right at the receiver, then other parts of the
> protocol need investigation/improvement.

I agree. It's a risk to work on the sender at the moment, implementing
these features,
algorithms and ending with a CCID that doesn't match the expected performan=
ce.
Can you list the pending tasks in both code and tests to be done?


Cheers,

Ivo

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
