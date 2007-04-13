From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 12:03:02 +0000
Subject: Sensitivity of TFRC throughput equation wrt to changes of RTT
Message-Id: <200704131303.03072@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The comment by Dave brought me back to check what a change of
a factor of 10 does to the throughput in TFRC. 

RFC 3448 gives in section 8 the following alternative format
of the throughput equation (which is directly responsible for
the alllowed sending rate X):

              s
      X =  --------
           R * f(p)

This shows that the dependence is reciprocal. Thus using an RTT
which differs by a factor of 10 to account for in-stack processing
results an a throughput reduction of factor 10.

In other words, 90 Mbits/sec becomes 9 Mbits/sec.
