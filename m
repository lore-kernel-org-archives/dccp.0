From: David Miller <davem@davemloft.net>
Date: Sun, 10 Dec 2006 05:55:20 +0000
Subject: warning on 64-bit from current code
Message-Id: <20061209.215520.63128166.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org


You guys are using different types for "r_sample" in two different
functions, and then passing that to CCID3_RTT_SANITY_CHECK, which
uses %ld for the format string, but the second case uses
'suseconds_t' instead of 'long' as the type:

net/dccp/ccids/ccid3.c: In function $,1rx(Bccid3_hc_rx_packet_recv$,1ry(B:
net/dccp/ccids/ccid3.c:998: warning: format $,1rx(B%ld$,1ry(B expects type $,1rx(Blong int$,1ry(B, but argument 2 has type $,1rx(Bsuseconds_t$,1ry(B

Please fix, thanks.
