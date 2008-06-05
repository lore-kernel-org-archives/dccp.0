From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Jun 2008 14:44:35 +0000
Subject: [dccp] [RFC/RFT] [Patch 0/2]: Test-tree update to handle
Message-Id: <20080605144435.GA8800@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here are two patches for the test tree. As with all RFC/RFT patches, these are
posted with the main objective of getting review/comments, and are then put into
the test tree for ... testing.

These patches evolved thanks to input provided by Wei Yongjun regarding an
unresolved problem with retransmissions, fixed by the following two updates:

Patch #1: allows to distinguish retransmitted from original packets,
          using a slight reordering of existing code.
          This is the main fix for the earlier problem of not incrementing
	  the sequence number properly on retransmitted Request packets.

	  The patch introduces a generic condition which can also be tested
	  by other code (e.g. for the retransmission of Close/CloseReq).

Patch #2: puts two strongly related statements, dccp_entail() and
          skb_clone() both in dccp_entail(), since they are not 
	  independent. Patch can be a matter of taste and may be omitted.


The patches are not yet committed - if there are no major objections, they will
be added to the test tree tomoroow, on 

	git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree dccp)

with snapshots on
	http://eden-feed.erg.abdn.ac.uk/latest-dccp-test-tree.tar.bz2
	http://eden-feed.erg.abdn.ac.uk/latest-dccp-test-tree.diff.gz
