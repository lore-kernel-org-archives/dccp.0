From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Mon, 27 Nov 2006 20:25:48 +0000
Subject: CCID 3 round-trip time measurement
Message-Id: <456B49CC.2080303@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

It has recently come to our attention that the CCID 3 RFC doesn't explicitly 
say that ANY valid RTT measurement may be used to update the CCID 3 RTT.  This 
wasn't the intent.  We [Sally & Eddie] propose to send in the following 
erratum.  Comments?

Eddie


RFC 4342, "Profile for Datagram Congestion Control Protocol (DCCP)
Congestion Control ID 3: TCP-Friendly Rate Control (TFRC)"

Reported By: Sally Floyd and Eddie Kohler, from Gerrit Renker
Date:

Section 5, 7th paragraph:
Explanation: Clarification of round-trip time measurement

It states:
    The sender's measurement of the round-trip time uses the Elapsed Time
    and/or Timestamp Echo option contained in feedback packets, as
    described in Section 8.2. The Elapsed Time option is required, while
    the Timestamp Echo option is not.  The sender maintains an average
    round-trip time heavily weighted on the most recent measurements.

It should say:
    The sender's measurement of the round-trip time uses DCCP's mechanisms
    for round-trip time measurement.  This includes Elapsed Time and/or
    Timestamp Echo options.  As described in Section 8.2, feedback packets
    must carry an Elapsed Time option; Timestamp Echo is optional.
    The sender maintains an average round-trip time heavily weighted on the
    most recent measurements.  Senders MAY use any available round-trip time
    measurements, including from the initial Request-Response packet exchange,
    to maintain this average.  This differs from [RFC 3448], which constrains
    round-trip time measurements to feedback packets only.
