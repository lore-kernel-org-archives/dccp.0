From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 12 Oct 2007 09:51:41 +0000
Subject: [PATCH 0/5]: Option headroom, MPS, and FIXME in dccp_sync_mss
Message-Id: <200710121051.42025@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A small self-contained patch set which centers around determining sufficient option
headroom when calculating the maximum packet size.

Patch #1: Adds documentation for the fields in struct ccid_operations.

Patch #2: More informative registration of CCIDs.

Patch #3: Introduces the CCMPS field for CCIDs. This is currently only used
          by CCID4. The ccmps value needs to include network/transport header
          lengths (since dccp_sync_mss subtracts these). For CCID4 this would
          supposedly look like (RFC 3714/4828):
	  struct ccid_operations ccid4 = {
		.ccid_mps = 1500,
		/* ... */
	  };
	  If the field is omitted or set to 0, no CCMPS is imposed.

Patch #4: Is the core of this patch set and estimates the minimally required option
          headroom for Data/DataAck packets. It addresses a FIXME in dccp_sync_mss.
          I have long thought about this and come to the conclusion that a simple
          solution - optimising for data transfer - is better. The complexities of
          variable-length options (Ack Vector, Data Dropped, initial feature-negotiation)
          need to use a different path - e.g. using a separate Ack (cf. next patch).
          Rationale and background is documented on 
          http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/misc_notes/estimating_option_sizes_for_MPS.txt

Patch #5: Reorders statements to estimate the maximum room left for Ack Vectors and adds a Fixme + warning
          message for dealing with insufficient remaining space when piggybacking on DataAck.
