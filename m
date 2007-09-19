From: Tommi Saviranta <wnd@iki.fi>
Date: Wed, 19 Sep 2007 16:20:29 +0000
Subject: mss in CCID 4 draft
Message-Id: <20070919162029.GA8457@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Since English isn't my native language, and because I have a habit of
making small uncertainties into big problems, I'd like to hear your
interpretation on this.

Introduction, the nominal segment size: "In TFRC-SP, the nominal segment
size used by the TCP throughput equation is set to 1460 bytes." What
kind of things are included in "TCP throughput equation"? Does this
apply to tfrc_calc_x() in ccid3_hc_tx_packet_recv(), and to scaled_div()
in ccid4_first_li()?

