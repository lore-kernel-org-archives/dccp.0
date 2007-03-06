From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 Mar 2007 09:36:36 +0000
Subject: [PATCH 0/2]: Bug fixes
Message-Id: <200703060936.36609@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here are two small bug fixes:

Patch 1: This fixes an error in splitting the CCID half connections:
         packets received on a listening socket are forwarded to the
         TX CCID where it should have been the RX CCID. 
         This is a bug but has not become visible so far and I am
         wondering whether this has any relationship with the bug
         reported by Andre. Would be very grateful for testing. 

Patch 2: Tracks a recent change made in in tcp_open_req_child
         where the RTO for the child socket was not set correctly.
