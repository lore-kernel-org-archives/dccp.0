From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Nov 2006 15:44:54 +0000
Subject: [PATCH 0/6]: CCID 3: packet scheduling and packet size EWMA patch
Message-Id: <200611211544.54258@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This change set contains the promised exponential moving average patch for
the CCID 3 packet size `s' plus a few other improvements.

Patch 1: Fixes a bug in calculation of first t_nom and first t_ipi
Patch 2: Simplifies control flow in the calculation of t_ipi
Patch 3: Fixes a problem in calculation of scheduled packet transmission
Patch 4: Simplifies ccid3_hc_tx_send_packet (also reads easier afterwards)
         --> here I have a question:
             return type of this function is `int', if return value > 0
             it means a delay in milliseconds. Is there any point converting
             the function to one returning type long or is it always certain
             that the return value is small enough that this doesn't matter?
Patch 5: The EWMA patch for packet size `s'
Patch 6: Tidies up left-overs from patch 5


Regards,

Gerrit
