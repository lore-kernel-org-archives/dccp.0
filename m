From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 13 Dec 2007 14:57:02 +0000
Subject: [DCCP] [Announce]: Ack Vector Implementation Notes
Message-Id: <20071213145702.GA18824@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I've been working on making DCCP Ack Vectors more robust, dealing more gracefully
with buffer overflow, and fixing two cases which will lead to corrupted buffer state.

The encountered problems and implementation strategy are documented on
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ack_vectors/

I'd be glad for feedback, in particular if there are any errors or points which may have been
overlooked.
