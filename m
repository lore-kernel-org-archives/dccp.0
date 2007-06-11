From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 14:39:17 +0000
Subject: [PATCH 0/5]: CCID3 simplifcations & update with regard to rfc3448bis-00
Message-Id: <200706111539.18003@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch bundle (also largely self-contained) contains

  a) some simplifications for CCID3;

  b) updates with regard to rfc3448bis. 
     These are experimental, but I think they can be of use for further development.

     Note: These updates patch set is likely to be subject to further revision. 
           Since rfc3448bis00 I have not bothered to update it since the
           changes were so frequent and so much other code (e.g. preventing
           oscillations, faster restart) depends on it. 
           I'd suggest to update this only after it has sufficiently stabilised
           and consider rfc3448bis00 as a sufficiently-stable basis until then.


Patch #1: Shortens a statement to update p.

Patch #2: Removes two internal states which are not relevant to processing.

Patch #3: Simplifies internal state machine by using value of t_RTO 
          as indicator for the state `no feedback at all has been received yet'.
          This test is required for some of the conditions that rfc3448bis uses.

Patch #4: Implements the new nofeedback timer handling from 3448bis

Patch #5: Update the packet-receive path with regard to changes from 3448bis

 
