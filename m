From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 28 Oct 2009 15:33:58 +0000
Subject: Re: Doubt in implementations of mean loss interval at sender side
Message-Id: <20091028153358.GA3456@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B861.7040107@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B861.7040107@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > This is a good point. Personally, I can not really see an advantage in
| > storing old data at the sender, as it seems to increase the complexity,
| > without at the same time introducing a benefit.
| >
| > Adding the 'two RTTs old' worth of information at the sender re-introduces
| > things that were removed already. The old CCID-3 sender used to store
| > a lot of information about old packets, now it is much leaner and keeps
| > only the minimum required information.
|
| So, how we can solve this? How can we determine if a loss interval is
| (or not) 2 RTT long in the sender?
|
Yes, I also think that this is the core problem.

To be honest, the reply had been receiver-based TFRC in mind but did not
state the reasons. These are below, which contains also a sketch.

In particular, the 'a lot of information about old packets' mentioned above
could only be taken out (and with improved performance) since it relied on
using a receiver-based implementation (in fact the code has always been,
since the original Lulea code).


I) (Minimum) set of data required to be stored at the sender
------------------------------------------------------------
RFC 4342, 6 requires a feedback packet to contain
 (a) Elapsed Time or Timestamp Echo;
 (b) Receive Rate option;
 (c) Loss Intervals Option.

Out of these only (b) is currently supported. (a) used to be supported,
but it turned out that the elapsed time was in the order of circa 50
microseconds. Timestamp Echo can only be sent if the sender has sent
a DCCP timestamp option (RFC 4340, 13.3), so it can not be used for the
general case.

The sender must be able to handle three scenarios:

 (a) receiver sends Loss Event Rate option only
 (b) receiver sends Loss Intervals option only
 (c) receiver sends both Loss Event Rate and Loss Intervals option

The implementation currently does (a) and enforces this by using a
Mandatory Loss Event Rate option (ccid3_dependencies in	net/dccp/feat.c),
resetting the connection if the peer sender only implements (b).

Case (b) is a pre-stage to case (c), otherwise it can only talk to
DCCP receivers that implement the Loss Intervals option.

In case (c) (and I think this is in part in your implementation), the
question is what to trust if the options are mutually inconsistent.
This is the subject of RFC 4342, 9.2, which suggests to store the sending
times of (dropped) packets.

Window counter timestamps are problematic here, due to the 'increment by 5'
rule from RFC 4342, 8.1. Using timestamps raises again the timer-resolution
question. If using 10usec from RFC 4342, 13.2 as baseline, the sequence
number will probably also need to be stored since in 10usec multiple
packets can be transmitted (also when using a lower resolution).

Until here we have got the requirement to store, for each sent packet,
 * its sending time (min. 4 bytes to match RFC 4342, 13.2)
 * its sequence number (u48 or u64)
Relating to your question at the top of the email, the next item is
 * the RTT estimate at the time the packet was sent, used for
   - verifying the length of the Lossy Part (RFC 4342, 6.1);
   - reducing the sending rate when a Data Dropped option is received, 5.2;
   - determining whether the loss interval was less than or more than 2 RTTs
     (your question, RFC 4828, 4.4).

To sum up, here is whay I think is minimally required to satisfy the union
of RFC 4340, 4342, 4828, 5348, and 5622:

	struct tfrc_tx_packet_info {
		u64	seqno:48,
			is_ect0:1,
			is_data_packet:1,
			is_in_loss_interval:1;
		u32	send_time;
		u32	rtt_estimate;
		struct tfrc_tx_packet_info *next; /* FIFO */
	};

That would be a per-packet storage cost of about 16 bytes, plus the pointer
(8 bytes on 64-bit architectures). One could avoid the pointer by defining a
	u64	base_seqno;
and then
	struct tfrc_tx_packet_info[some constant here];
and then index the array relative to the base_seqno.


IIb) Further remarks
--------------------
At first sight it would seem that storing the RTT also solves the problem
of inaccurate RTTs used at the receiver. Unfortunately, this is not the
case. X_recv is sampled over intervals of varying length which may or may
not equal the RTT.  To factor out the effect of window counters, the sender
would need to store the packet size as well and would need to use rather
complicated computations - an ugly workaround.

One thing I stumbled across while reading your code was the fact that RFC 4342
leaves it open as to how many Loss Intervals to send: on the one hand it follows
the suggestion of RFC 5348 to use 1+NINTERVAL=9, but on the other hand it does
not restrict the number of loss intervals. Also RFC 5622 does not limit the
number of Loss Intervals / Data Dropped options.

If receiving n > 9 Loss Intervals, what does the sender do with the n-9 older
intervals? There must be some mechanism to stop these options from growing
beyond bounds, so it needs to store also which loss intervals have been
acknowledged, introducing the "Acknowledgment of Acknowledgments"
problem.

A second point is how to compute the loss event rate when n > 9. It seems
that this would mean grinding through all loss intervals using a window
of 9. If that is the case, the per-packet-computation costs become very
expensive.


II) Computational part of the implementation
--------------------------------------------
If only Loss Intervals alone are used, only these need to be verified
before being used to alter the sender behaviour.

But when one or more other DCCP options also appear, the verification is
 * intra: make sure each received option is in itself consistent,
 * inter: make sure options are mutually consistent.

The second has a combinatorial effect, i.e. n! verifications for n options.

For n=2 we have Loss Intervals and Dropped Packets: the consistency must
be in both directions, so we need two stages of verifications.

If Ack Vectors are used in addition to Loss Intervals, then their data
must also be verified. Here we have up to 6 = 3! testing stages.

It gets more complicated (4! = 24 checks) by also adding Data Dropped
options, where RFC 4340, 11.7 requires to check them against the Ack
Vector, and thus ultimately also against the Loss Intervals option.


III) Closing remarks in favour of receiver-based implementation
---------------------------------------------------------------
Finally, both RFC 4342 and RFC 5622 do not explicitly discard the
possibility of using a receiver-based implementation. Quoting
RFC 4342, 3.2: "If it prefers, the sender can also use a loss event
                rate calculated and reported by the receiver."
Furthermore, the revised TFRC specification points out in section 7
the advantages that a receiver-based implementation has:
 * it does not mandate reliable delivery of packet loss data;
 * it is robust against the loss of feedback packets;
 * better suited for scalable server design.

Quite likely, if the server does not have to store and validate a mass
of data, it is also less prone to be toppled by DoS attacks.

| > As a second point, I still think that a receiver-based CCID-4 implementation
| > would be the simplest possible starting point. In this light, do you see an
| > advantage in supplying an RTT estimate from sender to receiver?
|
| Yes, better precision. But, at the cost of adding an option
| undocumented by any RFC's?
|
No I wasn't suggesting that. As you rightly point out, the draft has
expired. It would need to be overhauled (all the references have
changed, but the problem has not), and I was asking whether returning
to this has any benefit.

The text is the equivalent of a bug report. RFCs are like software - if no
one submits bug reports, they become features, until someone has enough of 
such 'features' and writes a new specification.
