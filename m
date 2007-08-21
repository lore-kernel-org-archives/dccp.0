From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 06:51:10 +0000
Subject: Re: [PATCH 02/15] Make ccid3_hc_tx_update_x get a timestamp if needed
Message-Id: <200708210751.10567@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070819234901.GF24792@ghostprotocols.net>
In-Reply-To: <20070819234901.GF24792@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  The code was too complicated, if p > 0 in ccid3_hc_tx_no_feedback_timer the
|  timestamp was being obtained to be passed to ccid3_hc_tx_update_x, where only
|  if p > 0 the timestamp was needed, so just leave it to ccid3_hc_tx_update_x to
|  obtain the timestamp if needed.
The `too complicated' is there for a reason, it served to reduce the number of timestamps
per packet.

With your patch, the code is now back at taking two timestamps per each received packet:

 * first a timestamp is taken for the RTT sample
 * whenever p = 0 (normal condition without loss), the second timestamp is now
   taken in ccid3_hc_tx_update_x()

Since this code is in the receive path, it is executed for each received
packet, i.e. two timestamps per each incoming packet.

The original code recycled the first timestamp; the timestamp in no_feedback_timer()
(which is only executed in exception cases, when there is no feedback for over 4 RTTs) was
taken only when absolutely necessary, if two `if' conditions held.

But this is not a big deal - I will send a patch shortly.
