From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Dec 2007 13:11:54 +0000
Subject: [PATCH 0/4] [TFRC]: Revised Loss Intervals Patches (macro-less, new swap function)
Message-Id: <1197292318-29659-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This revision updates earlier patches, following discussion,
and adds one additional cleanup patch at the end.


Patch #1: Revision of initialisation patch; fixed calling __exit function 
          from __init function - identified by Arnaldo.

Patch #2: Revision - re-converted tfrc_rx_hist_entry() back to inline,
          following discussion with Arnaldo.

Patch #3: Reworked - loss intervals database.  Individual changes:
     	  - replaced tfrc_rx_hist_swap() with routine suggested by Arnaldo;
	  - replaced all access macros with inlines or in-place(s);
	  - replaced LIH_INDEX also with inline instead of macro.
          
Patch #4: Removes redundant debugging output from syslog.
