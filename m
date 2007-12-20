From: Leandro <leandroal@gmail.com>
Date: Thu, 20 Dec 2007 16:58:40 +0000
Subject: [PATCH 0/8] Apply the new naming schema for ccid-3 and ccid4 funcs/strucs/fields and more code shari
Message-Id: <200712201358.40985.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,
   Please consider the following patches to be applied against ccid-4 branch.

Patch #1: Remove unnecessary comments to ccids code
Patch #2: Improve the declaration of tfrc_option_receive struct
Patch #3: Apply new naming schema for TFRC TX/RX states
Patch #4: Fix naming schema for tx-rx sock struct
Patch #5: Fix naming schema for option received struct
Patch #6: Share ccid3_hc_tx_parse_options function and rename it to the new naming schema
Patch #7: Fix name schema for option received struct
Patch #8: Remove inline modifier from tfrc_ccids.c functions

Thank you,
Leandro.
