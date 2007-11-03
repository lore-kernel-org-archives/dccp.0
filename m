From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Nov 2007 12:31:07 +0000
Subject: [RFC]: Removal of spinlocks/rw_locks in ccid3.c / packet_history.c:
Message-Id: <200711031350.20405@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

With regard to the previous patch 9/9 I wonder if it is possible to remove the Reader/Writer spinlock used 
in the test tree in packet_history.c (field member @lock in struct tfrc_rx_hist). 

If the socket is protected by the socket lock, and the same backlog handler does not run concurrently, then
the RX history rw_lock is redundant. I haven't changed anything, but am about to reformat the patches so that
each of them compiles standalone, it is a good time to address this.

The point that I find confusing here is that several new cards (e.g. e1000) can have multiple TX/RX queues
on the same card: I wonder whether that will make a difference to the DCCP sk backlog handler.

Comments?
