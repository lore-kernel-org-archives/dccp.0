From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 14:14:24 +0000
Subject: [PATCH 0/11]: Basis for feature negotiation
Message-Id: <200709271514.25022@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This now starts the feature-negotiation code and is the first batch of several.
I have been testing these for quite a while and believe they are bug free.

The concept for feature negotiation is new and mostly mapped onto the 3-way handshake.
Documentation is on http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/ 


Patch #1: Removes unnecessary code from option processing
          (I had originally introduced this out of misunderstanding the code)

Patch #2: Adds an explicit remark that all known-so-far SP values are 1-byte,
          which removes several XXX's present in the feature-negotiation code.

Patch #3: Stops option processing to parse feature-negotiation on Data packets
          (is not allowed as per RFC 4340, 6.1 and slows down).


Patch #4: The new feature negotiation code starts here - data structures and initialisation.
          (I believe what Frederic Brooks said that the structures are most important, since
           one can see from them already how the algorithms will be laid out).

Patch #5: In the spirit of patch #4, a lookup table is provided which forms the central 
          `intelligence' of the feature-negotiation code (has all the rules and defaults).

Patch #6: Adds list management functions (book-keeping). As before, the feature negotiation
          code is maintained as doubly linked list, which is smaller on average than using
          a full table on each (request) socket. But the list management code is entirely new;
          the most important points are: 
		- strictly ordered by feature number (faster lookup)
		- no duplicates (and the management code becomes simpler)

Patch #7: Adds feature-negotiation data structures (struct list_head) to DCCP sockets, and
          request sockets; and provides initialisation for using these socket fields.

Patch #8: Cleanup routines for the socket data structures of patch #7.

Patch #9: Documents a socket struct and asks whether it can be removed.

Patch #10: Restricts feature negotiation to connection setup, as documented on 
          http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/during_connection_setup.html
          Please note: this limitation is later lifted, to allow passing NN options during
                       an established connection (CCID2's Ack Ratio depends on that).           

Patch #11: We are no longer using retransmission timers for feature negotiation. This has been made possible
           by the concept documented on the above URL - it is mapped, with its dependencies, onto the initial
           handshake. Away go the timers.
