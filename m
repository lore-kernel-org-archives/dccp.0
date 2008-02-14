From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Feb 2008 13:48:21 +0000
Subject: [DCCP] [PATCH 0/5]: Extend CCID interface so that CCID-2 stops polling
Message-Id: <1202996906-29652-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This set of patches extends the packet sending/dequeuing interface, which is 
currently restricted to using time intervals only. This forces CCID-2 into
a constant polling mode, which is removed in patch #4.

Patch #1: Extends the CCID packet dequeuing interface to allow CCIDs to
          autonomously schedule sending. Previously it was timer-only,
	  so that CCID-2 polls uninterruptedly.
Patch #2: Adds a similar extension to the routine which drains the packet queue
          at the end of a connection (still under congestion control).
Patch #3: Please clean up your queue when disconnecting.
Patch #4: With the previous changes, CCID-2 is taken out of its polling mode.
Patch #5: Removes the `more' argument from tx_packet_sent.
