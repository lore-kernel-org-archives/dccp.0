From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 03 Nov 2006 14:31:46 +0000
Subject: [PATCH 0/6]: Debugging & partial checksum support
Message-Id: <200611031431.46644@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Five patches to support debugging, one to introduce partial checksumming.

Patch 1: re-introduces the Unload Hack (back by popular demand)
	 Without this patch it is currently not possible to unload
	 dccp_ipv{4,6}, not even with force. 
         The solution is simple, to make this more elaborate is a
	 non-trivial problem which is mainly of interest for 
	 developing where `no unloading' is a real nuisance.

Patch 2: resolves the problem that debugging only works when 
	 compiling DCCP as modules, and provides some generic macros

Patch 3: introduces a debugging configuration option for CCID 3

Patch 4: makes dccp_feat_change output a bit more readable - the output
         is like the description of feature negotiation in the RFC,
         which makes it easier to see what is going on. I have also added
         a few sanity checks - eventually this code needs some more care
         and attention.

Patch 5: cleanups, no code changes. Was split from patch 6 to make the
         latter easier to read, recognizing that many changes do not have
         to do with partial checksums.

Patch 6: Introduces DCCP partial checksumming support. This includes
	 socket options, receive processing and updates to checksumming
	 routines; it excludes the Min Checksum Feature and sending
	 data dropped options (but there are annotations where this is
	 missing, so do feel free and go ahead).

All patches apply on top of one another, I have just pushed them on top of
         http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/

The mapping is:

Patch 1: http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09a_release_ctl_socket_at_exit.diff
Patch 2: http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09b_tidy_up_config_debug.diff
Patch 3: http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09c_add_ccid3_debug.diff
Patch 4: http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09d_add_verbose_feat_output.diff
Patch 5: http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/10a_miscellaneous_tidy_ups.diff
Patch 6: http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/10b_partial_csum.diff

-- Gerrit
