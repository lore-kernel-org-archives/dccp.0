From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Wed, 31 Oct 2007 07:20:25 +0000
Subject: [PATCH 0/25] Towards CCID3/CCID4 code integration
Message-Id: <5bc4c4570710310020k32fcd84fr9ec0179e363b7bfe@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1193810064.7357.249.camel@embedded-ephone1.embedded.ufcg.edu.br>
In-Reply-To: <1193810064.7357.249.camel@embedded-ephone1.embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit,
   based on conversations with you, Arnaldo and Ian, please consider
the following patches related to ccid-4 initial implementation and
code share with ccid-3. Also, please reset the ccid4 branch to have
the latest dccp branch code before apply these patches series. It
would be interesting if you merge the patches related to code share
between ccid-3 and ccid-4 into the dccp branch to eliminate some of
our job and reduce (or even avoid) code repetition, in case that
ccid-3 is changed.
   Some considerations about the criterious that I used to share a
function/struct/consts between ccid-3 and ccid-4.

1 - Certify whether the function is common (checking just the
functions in ccid-4 copied from ccid-3);

2 - Certify whether both functions (in ccid-3 and ccid-4) still
common; (Me or Tommi can already changed it for ccid-4)

3 - Certify whether the both functions doesn't call a ccid specific function;
    i.e: ccid3_hc_tx_packet_sent could be shared, but it calls
ccid3_hc_tx_update_s, which is a ccid-3 specific function. Then
ccid3_hc_tx_packet_sent is not a candidate to be shared between
ccid-{3/4}.
    i.e: ccid3_hc_rx_packet_recv
    i.e: ccid3_hc_rx_insert_options

4 - Certify whether the function has a low probability to be changed
for ccid-4 implementation in the future;
    i.e 1: Albeit ccid3_hc_tx_send_packet could be common, ccid-4 will
probably have a particular way to decide when send a packet
    i.e 2: ccid4_first_li will certainly change because the short loss
interval length is calculated as N/K, instead of using just N
(ccid3_first_li).
    i.e 3: ccid3_hc_tx_parse_options could be common, but until the
IETF folks do not decide if DROPPED_PACKET_OPTION will be into the
ccid-3, I decided to NOT share it.

5 - Common sense: functions such as ccid3_hc_tx_init and
ccid3_hc_tx_exit are very particular, probably we will want to have
specific procedures to go into ccid-3, different to ccid-4 and
vice-versa.

Patch #1: [CCID-4] Changes to Kconfig and Makefile to add ccid-4 code;
Patch #2: [CCID-4] New ccid-4 based on ccid-3 source code;
Patch #3: [CCID-4] Adjustments of the ccid-4 copyright and kernel
module authors;
Patch #4: [CCID-4] Set packet size to 1460 as per ccid-4 draft;
Patch #5: [CCID-4] Enforces a minimum interval of 10 milliseconds as
per CCID-4 draft;
Patch #6: [CCID-4] Reduce allowed sending rate by a factor that
accounts for packet header size;
Patch #7: [CCID-3/4] Initial lib for sharing common code between ccid-3/ccid-4;
Patch #8: [CCID-3/4] Share common header files and defines between
ccid-3/ccid-4;
Patch #9: [CCID-4] Adapt CCID-4 according to the latest changes to CCID-3;
Patch #10: [CCID-3/4] Share ccid-3 options enum and struct via ccid34_lib;
Patch #11: [CCID-3/4] Share TFRC sender states via ccid34_lib;
Patch #12: [CCID-3/4] Share TFRC receiver states via ccid34_lib;
Patch #13: [CCID-3/4] Share TFRC feedback types struct via ccid34_lib;
Patch #14: [CCID-4] Basic implementation for ccid-4 dropped packet
option as per ccid-4 draft;
Patch #15: [CCID-3/4] Share ccid3_hc_tx_sock struct and ccid3_hc_tx_sk
function via ccid34_lib;
Patch #16: [CCID-3/4] Share ccid3_hc_rx_sock and ccid3_hc_rx_sk via ccid34_lib;
Patch #17: [CCID-3/4] Share ccid3_tx_state_name function via ccid34_lib;
Patch #18: [CCID-3/4] Share rfc3390_initial_rate function via ccid34_lib;
Patch #19: [CCID-3/4] Share ccid3_hc_tx_idle_rtt function via ccd34_lib;
Patch #20: [CCID-3/4] Share ccid3_hc_tx_update_win_count function via
ccid34_lib;
Patch #21: [CCID-3/4] Share ccid3_rx_state_name function via ccid34_lib;
Patch #22: [DCCP] Minor adjustments to probe.c to use ccid34_lib;
Patch #23: [CCID-4] Include ccid-4 to be visible for the DCCP feature
negotiation mechanism;
Patch #24: [DCCP] Final adjustments to probe.c to use ccid34_lib;
Patch #25: [CCID-3/4] Final adjustments to ccid3.c, ccid4.c and
lib/ccid34_lib.c.

Leandro.
