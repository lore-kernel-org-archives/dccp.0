From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 21 Jul 2007 14:58:48 +0000
Subject: [PATCH 0/1][RFC]: Drop `accumulation of large send credits' patch
Message-Id: <200707211558.48679@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

While bisecting I found that the DCCP packet scheduler now reacts much
differently from the one 2.6.20 (which was up to three times too fast).

The new experimental data, taken on a 2.6.22 tree with the DCCP test tree patches,
shows that 

 (1) the packet scheduler now reacts accurately with regard to the value of t_ipi;
 (2) the send-credits patch is no longer necessary and in fact degrades performance.

I would therefore like to drop this patch from the test tree.

The results are here:
 http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/packet_scheduling/2.6.22-scheduler/	


The most drastic example was a laptop with HZ%0
 * 2.6.22 netdev as of 20/7:   84.6  Mbits/sec
 * DCCP test tree as of 20/7:   4.33 Mbits/sec !!!
 * DCCP test tree patched:     92.8  Mbits/sec


I would be grateful for any test results and continue to look for further causes
of the bad performance with the TBF bandwidth restriction.

Any input, suggestions, test reports are welcome.
