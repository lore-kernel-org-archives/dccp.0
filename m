From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:08 +0000
Subject: [PATCH 0/11]: Encoding, inserting, and processing Feature-Negotiation options
Message-Id: <200710011518.08134@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



Patch #1: Increases the find-smallest-optlen function to go up to 6 bytes
          which is the maximum for Seq Window and NDP count; and adds a Fixme,
          since some of the code still refers to an older draft using 3-bytes
          NDP count (wireshark was the same).

Patch #2: In the same manner, the scope of the variable-length htonl/ntohl
          functions dccp_{de,en}code_value_var() is increased to up to 6 bytes.

Patch #3: Resolves the problem raised in patch#1 and updates NDP count usage from
          3 to 6 bytes. The CCID3 code got an overflow warning instead of a full
          update: let's first wait and celebrate the first connection to hit an
          NDP count of 2^32-1. Until that happens, many other problems can be resolved.


Patch #4: An dccp_insert_mandatory_opt() to add Mandatory option support (RFC 4340, 5.8.2)

Patch #5: Update for the dccp_insert_feat_opt() routine (more checks, more functionality).

Patch #6: The Feature-Negotiation end of the insert-into-skb business. This function now
          calls the function in options.c. Unlike before, the interfaces between option-inserting
          code and feature-negotiation code are now separate, connected via this function.

Patch #7: Integrate insertion of feature-negotiation options at the server and the client (glue
          patch for #5 and #6).


Patch #8: Routines for (a) reconciling SP preference lists, (b) reordering a preference list
          so that a now-preferred entry comes first.

Patch #9: Support for filling in the Data 1..3 fields when option processing encounters an error.

Patch #10: Process incoming Change L/R requests. This is done in a combined routine now, since the
           code takes two different paths:
		- feature-negotiation during connection setup
		- passing of NN options (such as Ack Ratio) in establihed socket state

Patch #11: Process incoming Confirm L/R responses. The internally-called function is still separate.





