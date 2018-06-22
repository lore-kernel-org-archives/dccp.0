From: Eric Dumazet <edumazet@google.com>
Date: Fri, 22 Jun 2018 13:44:13 +0000
Subject: [PATCH net 0/2] net: dccp: fixes around rx_tstamp_last_feedback
Message-Id: <20180622134415.104266-1-edumazet@google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch series fix some issues with rx_tstamp_last_feedback.

- Switch to monotonic clock.
- Avoid potential overflows on fast hosts/networks.

Eric Dumazet (2):
  net: dccp: avoid crash in ccid3_hc_rx_send_feedback()
  net: dccp: switch rx_tstamp_last_feedback to monotonic clock

 net/dccp/ccids/ccid3.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

-- 
2.18.0.rc2.346.g013aa6912e-goog

