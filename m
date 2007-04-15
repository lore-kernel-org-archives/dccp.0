From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Sun, 15 Apr 2007 21:34:26 +0000
Subject: RTT measurement, CCID3 implementability
Message-Id: <46229A62.9010805@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

- The DCCP specification does not require RTT measurements on every packet 
exchange.

- It should be possible to use coarse grained timestamps (even jiffies) for 
most packets, with finer grained timestamps used on occasion, to improve the 
current estimate; for example, getting the time of day once per RTT.

- Further discussion of precise RTT measurements in the context of DCCP should 
be accompanied by comparisons with NewReno TCP throughput under the same 
experimental conditions.  (I.e., not CBR traffic as in Gerrit's web pages, and 
not TCP BIC or CuBIC or any fancier, nonstandard TCP.)  TFRC aims to obtain 
within a factor of 2 of a TCP NewReno sender's performance under the same 
conditions, and over the long term.  There is no point in abstract 
comparisons.  What does a crappy network card do to NewReno TCP?  I am 
curious; maybe things will look bad for CCID3, maybe they will look less bad.

- Gerrit has come to strong conclusions about the "implementability" of CCID3. 
  The evidence is supposedly here:

http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/packet_scheduling/
http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/impact_of_tx_queue_lenghts/

It's worth looking at these pages once again; the conclusions are far from the 
evidence.  A subset of strategies that have not been considered:

   = Limited Bursts (of more than 2 packets, but less than 10000).

   = Other methods of scheduling packet transmissions at sub-timer 
granularity, other than hrtimers.  For example, in response to ack arrival 
(would be helpful at low RTTs, where acks arrive quickly; in fact, if this was 
helpful, one might even have the CCID3 receiver send more acks than the 
minimum required by the spec).  Or in a kernel tasklet that might be scheduled 
only when a DCCP connection wants to send at high rates.

   = Reducing RTT measurements by compensation factors.

   = Accounting for send delay by attaching SKB destructors or similar callbacks.

Many of these have been mentioned at least once in previous emails, and 
summarily dismissed.  Time will tell.  It took months for "use the 
request/response exchange for an RTT measurement" to filter into the 
implementation, whereupon it was, as a predicted, a useful simplification.

- On 4 October 2006 I sent mail to the other DCCP coauthors wondering whether 
"a rate as the basic unit of congestion control ...is just too much of a pain 
in the ass to implement".  We will keep thinking about this, and there are 
alternatives to rate-based CC.  As yet it is too early to tell.  On the other 
hand, had we been implementing a modern TCP, I bet Gerrit would declare TCP 
unimplementable.

Eddie
