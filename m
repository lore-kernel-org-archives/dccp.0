From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 09 Jan 2007 13:21:00 +0000
Subject: CCID 3 question: length of the `open' loss interval I_0
Message-Id: <200701091321.00592@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Eddie, 

sorry to trouble you with yet another question, but it is extremely important to get this
right. This concerns the length of I_0, the interval since the most recent loss event.

In the current implementation, we are relying on the highest sequence numbers received
before a loss occurred. Using the terminology from [RFC 4342, 10.2], this corresponds
to X_prev and Y_prev.

For subsequent loss intervals (assuming that more than 1 RTT lies between X_prev/Y_prev),
we can compute the loss interval length [RFC 3448, 5.3] as modulo-2^48 distance between
X_prev and Y_prev.
( Strictly speaking, the first packet known to be lost - starting the loss event - 
  has sequence number (X_prev + 1) % 2^48. Since the next loss event begins at sequence 
  number (Y_prev + 1) % 2^48, the distance is however the same as from X_prev to Y_prev. )

With the open loss interval I_0, however, the situation is different. In [RFC 3448, 5.5],
I_0 is defined as "the number of packets received since the last loss event". Taking this 
literally means the following:

  * at the instant this loss is detected,              I_0 = 3 
    (since NUMDUPACK=3 packets need to be received to identify a loss event)
  * when the first data packet after the loss arrives, I_0 = 4,
  * when the i-th  data packet after the loss arrives, I_0 = 3 + i
  * ... and so on until the next loss is detected 

Question: Is this reasoning correct, or is the intention to determine the number of 
          data packets in I_0 by using X_prev and simply subtracting X_prev from the
          sequence number of the currently received packet (modulo 2^48)? 
          

The first variant seems to be conform with the RFC, the latter is conform with the way 
the other loss intervals are computed.

Resolving this will help to clear up the loss detection algorithm we are currently using.

Gerrit
