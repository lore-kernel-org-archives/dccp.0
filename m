From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 06 Dec 2005 19:01:31 +0000
Subject: initial CCID2 implementation for linux
Message-Id: <20051206190131.GA834@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

http://darkircop.org/acme-ccid2-20051206.diff

it's a diff from today's:
git/acme/net-2.6.16.git

To use it, you need to compile support for ack vectors and:
setsockopt DCCP_SOCKOPT_CCID_RX and DCCP_SOCKOPT_CCID_TX to 2.


CCID2 status:

* Standard TCP congestion control:
  - AIMD of cwnd, slow start etc.

* RTO timeouts:
  - Maintains RTT estimate and calculates RTO from that.
  - Doesn't support timestamp option.

* Ack ratios [reverse path congestion control]:
  - Supported by "infrastructure"
  - Missing feature negotiation, so no ack ratio change.

* ECN:
  - Correctly adjusts cwnd when packets are reported ECN marked.
  - Doesn't deal with ECN nonces.
  - No ECN support for reverse path congestion [receiving ECN marked ACK].

* No support for determining that flows go silent [ack an ack stuff].


I need to make the code solid and linux friendly.  Then I will split the patch
so hopefully arnaldo will agree to commit it.  It currently includes, and will
be split to:

* connect() race condition:
  Connect, send and disconnect real fast.  I don't remember details but,
  The socket will be transiting from SS_CONNECTING to SS_CONNECTED.  However,
  connect will return -1 because DCCP will have moved to CLOSE by the time
  connect() checks status.

* disconnect doesn't cleanup state:
  server sends close req.  Client doesn't reply with close "fast enough".
  Server will never destroy socket.  I still gotta think about this more though.

* support for ack vector records

* support for switching ccids

* support for ccid2


Any feedback is appreciated.  Specifically, if this code looks "promising" [i.e.
eventually commitable], it would be nice if someone can indicate the major
problems with it. [coding style, way of doing things, bugs, etc]

I'll now work on making the code more solid and splitting the patches.
