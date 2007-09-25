From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 14:23:50 +0000
Subject: [PATCH 0/8]: Preparatory patches for feature negotiation
Message-Id: <200709251523.50165@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A small set of patches to prepare feature negotion, and one miscellaneous one.
I will start step by step, the patches will be put into the test tree after the
last batch has been set (although this time I made sure that patch sets also
compile separately).

Patch #1: Accounting, records an unused function.

Patch #2: Adds Data 1..3 fields to do more informative
          processing of DCCP-Resets (RFC 4340, 5.6)

Patch #3: Removes duplicate code for generating Reset
          from connected socket (now uses already prepared
          route via dccp_transmit_skb).

Patch #4: Factors out common code for sending Resets from 
          control sockets. This includes processing the
          Data 1..3 fields for Packet/Option/Mandatory Error.

Patch #5: Parsing options on request_socks, a prerequisite
          for implementing feature-negotiation during 
          connection setup.

Patch #6: Integrates the code of Patch #5 with the processing
          in dccp_check_req, so that options can be considered
          by the server during the initial handshake (is a FIXME).

Patch #7: As the first option to be parseable on both request_socks
          and connected socks, timestamp echo is made dynamic.
          There are hooks/ideas there of turning this into a RFC1323-like
          algorithm, which however requires some more work (to deal correctly
          with delayed, lost, duplicate packets/timestamps).

Patch #8: Rounds off this request-sock patch set by adding support for
          inserting options from request_socks as well (as opposed to sk's).



