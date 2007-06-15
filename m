From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:10 +0000
Subject: [PATCH 0/9]: A new TFRC RX history structure and integration into CCID3
Message-Id: <200706151531.10559@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch introduces a new RX history structure exported as a service of
the dccp_tfrc_lib module.

The data structure is heavily optimised to reduce the overhead to the
smallest possible minimum. 

It takes care of both loss detection (loss handling follows in subsequent bundle)
and receiver RTT sampling.


Patch #1: Introduces the data structure plus a few elementary functions which use it.

Patch #2: Performs basic integration of the TFRC data structure with CCID3.

Patch #3: Initialisation (constructor) and clean-up (destructor) routines.

Patch #4: Introduces algorithm to always track the highest-seqo-received.

Patch #5: Receiver RTT sampling, part 1/3 - optimised algorithm to track RTT samples.
Patch #6: Receiver RTT sampling, part 2/3 - utility function to mark DCCP data packets.
Patch #7: Receiver RTT sampling, part 3/3 - integration into existing CCID3 code.

Patch #8: Update the CCID3 receive path to use the new TFRC RX structure + RTT sampling.

Patch #9: Integrate the loss handling based on new RX history into CCID3. Much more
          loss handling will follow in the subsequent patch bundle: in the end, the 
          TFRC module performs the whole task of loss detection, accounting, and initialising
          and recycling the data structures.
