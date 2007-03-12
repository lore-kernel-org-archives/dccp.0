From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 12 Mar 2007 15:57:12 +0000
Subject: [ANNOUNCE]: Patch Preview
Message-Id: <200703121557.12709@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have put quite a lot of work into
  * bringing CCID 3 up to spec
  * implement loss detection according to RFC 3448/4342
  * add loss intervals handling according to rfc3448bis
  * many cool new features
  * ample documentation, applications, and test modules for most features

However, since patches are small for review-ability, this amounts to a total of 75 patches,
including the patch backlog; please see suggestion (2).
 
1. PREVIEW: Since mostly the following files are modified:
      net/dccp/ccids/lib/ccid3.*
      net/dccp/ccids/lib/loss_interval.*
      net/dccp/ccids/lib/packet_history.*
   I have posted combined patches onto 

   http://www.erg.abdn.ac.uk/users/gerrit/dccp/patches_working-set/

   These apply in-order (see series file) onto today's tree. They have been extensively tested,
   can offer a test module for most essential features.


2. SUGGESTION: Since the patch backlog is really quite old now (over 2 months), I would like
   to suggest to re-submit it as one, combined patch, in the format of
   http://www.erg.abdn.ac.uk/users/gerrit/dccp/patches_working-set/01_The_Patch_Backlog.diff
   (maybe a bit more verbose)
   => But this depends on whether people are ok with this (see (3))


3. MISSED? I am not sure if I have missed Sign-offs or Acked-byes. Ian (and others) can you please
   check that http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/
   is correct? In particular, only the following two out of 25 are not acked/signed-off:
    * http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/3e_CCID3_send_time_race_condition.diff
      (but I believe you said you were ok with it, since the patch was changed  to update t_ipi when `s' changes)
    * http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/4a_debug_always_no_module.diff

4. SUMMARY of patch sets 2 and 3:

  	* avoiding accumulation of sending credits
	* faster & more efficient time-stamping (timestamps from NIC)
	* honour initial (SYN handshake) RTT estimate
	* implement rfc3448bis nofeedback timer handling
		- ignore feedback after nofeedback timer expiry when p=0
		- do not reduce X after nofeedback timer expiry
	* implement larger initial windows as described in rfc3448bis 
	* resolve locking issues for SMP 
		- atomic context between sending packet & updating CCID structures
		- atomic context when updating t_nom
		- protect transmitter data structures against asynchronous changes
		- keep garbage collection separate from access
	
	* clean up and minimize socket data structures
	* allow retrieving current Maximum Packet Size via socket option
	* compilation fixes for 64-bit architectures
	* function for distinguishing `data' and `non-data' (NDP) packet types
	* routines to perform modulo-16 (window counter CCval) arithmetic
	* simplify the kernel API (split functionality into modules)
	* completely revised RX history structure
		- circular list using only minimum of entries
		- object-oriented programming interface (like abstract data type)
		- reusing the same structure for both RTT sampling and loss detection
		- generic service, available to other CCIDs
	* loss detection
		- cope with delayed, late, and re-ordered packets
		- detect when a sequence hole is later filled
		- take NDP information into account
		- assign losses of the same RTT to the same loss event
		- recycle history structures after loss detection (cope with loss bursts)

	* loss interval management
		- also ring list since simplifies interface
		- object-oriented programming interface (like abstract data type)
		- on-demand allocation: less memory consumption on loss-free connections 
		- handing over from loss detection to loss interval history completely automated
		  by module (reusable for future CCIDs)

Enjoy,
Gerrit  
