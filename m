From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 01 Apr 2008 09:44:11 +0000
Subject: [PATCH 2/2] [CCID-3]: Remove duplicate documentation
Message-Id: <1207043051-27165-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes RX-socket documentation which is either duplicate or non-existent.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -130,16 +130,12 @@ enum ccid3_hc_rx_states {
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
- *  @x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
- *  @rtt  -  Receiver estimate of rtt (non-standard)
- *  @p  -  Current loss event rate (RFC 3448 5.4)
  *  @last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @state  -  Receiver state, one of %ccid3_hc_rx_states
  *  @bytes_recv  -  Total sum of DCCP payload bytes
  *  @x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
  *  @rtt  -  Receiver estimate of RTT
  *  @tstamp_last_feedback  -  Time at which last feedback was sent
- *  @tstamp_last_ack  -  Time at which last feedback was sent
  *  @hist  -  Packet history (loss detection + RTT sampling)
  *  @li_hist  -  Loss Interval database
  *  @s  -  Received packet size in bytes
-- 
1.5.3.GIT



The University of Aberdeen is a charity registered in Scotland, No SC013683.

