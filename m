From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 20 Nov 2006 16:05:20 +0000
Subject: [PATCH 0/2] [RESEND/UPDATE]: Message Scheme, McDonald Patches
Message-Id: <200611201605.20853@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This set contains
	* an update of  my patches from Friday
	* Ian's patches


1) Reason for update
--------------------
   The whole point of the message-macro scheme was to allow an easier migration later on
   to the well-known counterparts BUG(), WARN_ON(), BUG_ON(). These however issue a panic
   which stops the machine. Now, patch xx/7 sent in the last batch replaced BUG/BUG_ON with
   the DCCP counterparts. This is *not* a good idea, since these tests are in places where
   continuing would mean entering an undefined state. I therefore retract the said patch
   and have updated the others as pointed out below.


2) What changes:
----------------
	* Patch 1      (Ian's tx_qlen patch) remains as 9z.
	* Patch 2      (message scheme) will be re-sent as one patch (10a) instead of 7 single ones
	* Patch 3      (socket annotations) will be re-sent as second patch (10b)
	* Patch 4..6   are Ian's patches from Sunday and are not re-sent, but simply and shamelessly 
                       stacked them on top of all other patches as 11a .. 11c   
                                   

3) Detailed breakdown of changes with regard to the earlier cset
----------------------------------------------------------------
Patch 2:        Simplifications for ccid3.c 
              - remains as  before

Patch 3:      - CHANGED:
	      - removed superfluous DCCP_WARN_ON  (no point using a DCCP_XX wrapper)
Patch 4:      - Migration towards DCCP_BUG{,_ON}() 
	      - RETRACTED: due to reasons above
Patch 5:      - Migration towards DCCP_WARN_ON();
	      - RETRACTED: DCCP_BUG_ON is the same as WARN_ON, so not necessary
              - remainder of Patch 4/5; replaces unconditional BUG_ON(1) / WARN_ON(1)

Patch 6:      - remains as before
Patch 7:      - remains as before

Patch 8:      - done the FIXMes

-- Gerrit
