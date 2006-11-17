From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 15:56:50 +0000
Subject: [PATCH 0/7]:  message scheme tidy-up, tx_qlen, documentation
Message-Id: <200611171556.51081@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This includes mostly Ian's tx_qlen patch, the promised tidy-up of the WARN/BUG
message scheme, and some trivial things.


Patch 1: This is Ian's tx_qlen updated tx_qlen patch.
         I have removed the #define again (and was the one who suggested it);
         it seemed not to be a good idea after all (looking at net/dccp/dccp.h).


Patch 2: Adds the missing simplifications which were dropped somewhere inbetween
         trying with and without using enum:8 for CCID 3 states. With that in place,
         many conditions can be simplified, as is now done.


The remaining patches are very trivial and have not been sent as a single patch
in order to make the changes more clear when just reading through these. 



Patch 3: Implements a consistent set of WARN/BUG messages as per list discussion.

Patch 4: Migration towards DCCP_BUG()/DCCP_BUG_ON(). The benefit is that these macros
         will also inform about which condition was violated, in addition to line/file number.

Patch 5: Migration towards DCCP_WARN_ON(); same as in patch 4. Again, the difference is that
         now the warning conditions are printed out as well.

Patch 6: Adds a rate-limited DCCP_WARN() wrapper. 
         In addition, it adds warning messages about RTT reaching zero in CCID 3 (as per
         earlier this discussions; maybe this should be promoted to DCCP_CRIT()).

Patch 7: After being brain-damaged from doing so many repetitive things, I thought to add
         to this by completing the structure documentation for the rx/tx sockets. Ian can
         you please scream should I have erred somewhere (had one eye one the spec, though).

After this patch, the entire code has been updated with regard to this scheme. 
What has been left is BUG_TRAP(), which I think should be left since adding a DCCP-specific
wrapper around it would not make much sense.
NB: Most of the ``severe-warning'' macros do not need a terminating linebreak.

Mapping wrt http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/ :

Patch 1     -  09z_tx_queue_len_via_sysctl_McDonald.diff
Patch 2..7  -  10{a..g}_*.diff
