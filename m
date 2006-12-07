From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:12:10 +0000
Subject: [Patch 0/12]:
Message-Id: <200612072112.10572@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here is the latest batch of updates for CCID3. I held it back for almost two
days, got bogged down by testing. 

As an experiment (not part of the patch set), I tried to set the tx timestamp not
in ccid3_hc_tx_packet_sent but in ccid3_hc_tx_send_packet. The result was that on SMP
computers I got several bug messages that "r_sample < 0" (in ccid3_hc_tx_packet_recv).

This is a hint that the mysteriously high RTT values have to do with the way the history
is updated.

I am almost fully convinced that it is necessary to armour the packet history list
operations with read/write locks. The reasons:

 * list manipulation is asynchronous, packet_sent/send_packet fill the list, while
   packet_recv purges

 * send_packet may sleep so that meanwhile new entries are put on top
 
 * after applying patch 9 I got, for the first time, accurate RTT values [patch 9
   puts all history work into packet_sent]

It would be good to have further opinions/ideas on this.


Here is now the overview:

Patch  1: completes the migration towards using scaled_div/scaled_div32, by
          updating the TFRC calculation also.

Patch  2: attempts to reduce CPU load by only delivering to the CCID module
          which is currently active, to avoid unnecessary processing.

Patch  3: warns when discarding a TX packet; also, EINTR is no longer a bug case.

Patch  4: reduces ccid3_hc_tx_insert_options, since currently all its operations are 
          redundant.

Patch  5: takes care that the RTT values are all initialised properly.

Patch  6: sanity-checks RTT values. Thanks Ian :-)

Patch  7: puts all window counter updating functionality into an extra routine.

Patch  8: Removes the unused dccphtx_ccval field - it is used nowhere and not needed.
          =>  Note: The same holds for the u32 field `dccphtx_rtt' - it is
                     also not needed by the code. Shall it also be removed ??? 

Patch  9: concentrates all history updating in packet_sent. I believe that this is 
          much cleaner and could already observe much shorter RTT values than usual.

Patch 10: clerical - unifies the output format of debugging messages (less confusing).

Patch 11: clerical - I had difficulties reading packet_history.h since rx/tx function
          declarations are intermingled. This just reorders them to appear separate and
          following the same order of declarations.

Patch 12: clerical - does the same as patch 11, but for the source file.
