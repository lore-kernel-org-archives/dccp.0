From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 16 Apr 2007 19:44:48 +0000
Subject: [PATCH 1/1]: Retraction of timestamps - Cleanups
Message-Id: <200704162044.48664@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Apologies for this late follow-up. I have spent an entire
day going through the patches again, checking again the
changes made on Friday.

I had missed one or two instances of skb_get_timestamp, these
were better hidden. There are now no more left and the patch
set has been compile tested on 5 different machines.

Furthermore, I found a bug in the computation of CCID3 elapsed
time when sending feedback, it is one of the older bugs and
had not occurred to anyone before.

The problem is that the `elapsed time' reported by the receiver
is merely the time difference between calling the functions
rx_packet_recv() and rx_send_feedback(). This amounts on the average
to 50 .. 100 usec. 
With regard to RTT estimation, this is almost entirely useless.

Following is therefore a patch which tackles this problem with an
alternative approach, I believe it is a bit better.

I have left in the clean-up operation of removing the last instance
of skb_get_timestamp, hope that this is ok.

Due to the patch inter-dependencies, this patch is between the others,
uploaded as

        10e_CCID3-TIMESTAMP-FIX.diff


Thanks.
