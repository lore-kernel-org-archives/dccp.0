From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:24 +0000
Subject: [PATCH 0/14]: Finish up the feature negotiation during connection setup
Message-Id: <200710031502.25186@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This batch finishes the feature-negotiation during connection setup. The remaining
batch considers exchanging FN options in established state, which is a different
kettle of fish.

Patch #1: Introduces feature-activation handlers to dynamically
          activate feature values after negotiation.

Patch #2: Integrates dynamic activation with socket initialisation (the full code
          for pre-negotiation initialisation follows in patch #10).

Patch #3: Integrates dynamic activation with cild-socket creation.

Patch #4: Integrates dynamic activation at the client, before entering PARTOPEN.



Patch #5: Cleans up now unused bits of the infrastructure and updates copyrights.

Patch #6: Removes now unused bits of the CCID interface.

Patch #7: Removes test for LISTEN state in ccid3.c - CCIDs are now loaded only in
          OPEN/PARTOPEN state.

Patch #8: Removes manual influence on NDP count feature - this is a CCID dependency.

Patch #9: Replaces the use of the boolean Ack Vector flag with an equivalent test 
          whether Ack Vectors are in use on the socket.



Patch #10: Initialisation framework for feature negotiation (pre-negotiation setup). 

Patch #11: Auto-load CCIDs as part of the pre-negotiation setup. All advertised CCIDs
           are pre-loaded, since feature negotiation is mostly in interrupt context. 
           The modules are then ready to be used after the negotiation has converged.



Patch #12: Implement both sides of the Sequence Window feature (currently only one side
           has been implemented).

Patch #13: Initialisation and type-checking of FN sysctl values.

Patch #14: Debugging and pretty-printing routines for feature negotiation.
