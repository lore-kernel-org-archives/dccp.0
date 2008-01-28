From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jan 2008 10:16:10 +0000
Subject: [DCCP] [Patch 0/6] [BUG-Fix]: Fixes for CCID3, seqnos, and dccp_probe
Message-Id: <1201515376-8280-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a set of bug fixes for CCID3 and general DCCP. 

Please consider patches #1, #2, #3. The remainder are for the test tree
(but are fixes nonetheless) and may not apply directly onto mainline; with
regard to patch #6, please see note at end of message.

Patch #1: Fixes a CCID3 bug: when loss was encountered, the value returned at 
          minimum resolution was wrong and over 80 times too high.

Patch #2: Fixes a bug in the assignment of GAR (used ISR instead of ISS).

Patch #3: Another bug fix: AWL was only ever set after the Response.

Patch #4: Fixes adjustments to AWL and SWL. These were only updated at the
          begin of the connection (where the statements reduced to much 
          simpler assignments), but need to be adjusted for the reception
	  of subsequent packets also.
	  (Note: This patch is best used after going through the feature
	         negotiation patches, since the feature handlers for Sequence
		 Window ensure that these values are up to date.)

Patch #5: As a consequence of the preceding patches, the dccp_connect_init
          function may be merged into dccp_connect. Is a suggestion (which
          would make sense), not a bug fix.

Patch #6: A fix for dccp_probe - this used to be noisy and created huge
          files. By attaching the dccp_probe onto a different function, this
	  was fixed, the output file size shrank by a factor of over 100,
	  with qualitatively the same or better output.


I have put these after the feature-negotiation patches onto

	git://eden-feed.erg.abdn.ac.uk/dccp_exp 	{dccp,ccid4}

and updated the CCID4 tree to take advantage of the dccp_probe update.

If people would like to use the dccp_probe update for a mainline kernel,
I have uploaded a similar patch to patch #6 onto
http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe_for_mainline.diff
