From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Dec 2007 11:28:34 +0000
Subject: [RFC][Resend][PATCH 0/7]: CCID3/TFRC RX history and loss intervals implementation
Message-Id: <11966813201725-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am re-submitting the original patch set which Arnaldo referred to, due to:

 1/  It has been reworked to patch/compile against the 2.6.25 tree, which lead
     to a few changes (not conceptual in nature).

 2/  Patch #7 in Arnaldo's set says that this patch set introduced some bugs.

     Please can you point out if and what those are, so that they can be fixed (just
     saying that there are bugs without saying where they are is not very helpful).

Overview:
---------
Patch #1: Provides a central module source file for dccp_tfrc_lib.
Patch #2: Implements a new (reduced) RX history interface.
Patch #3: Hooks CCID3 up with the new RX history interface.
Patch #4: Removes the old/previous RX history interface.
Patch #5: Ringbuffer-based loss intervals database.
Patch #6: Interface CCID3 with loss intervals database. 
        
The algorithms that are implemented here have been documented on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/
