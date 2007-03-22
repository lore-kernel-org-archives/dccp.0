From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 Mar 2007 13:44:21 +0000
Subject: DCCP Applications Page
Message-Id: <200703221344.21777@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have uploaded newer versions of ttcp and iperf to 

  http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/

These make use of the new GET_CUR_MPS socket option to set the output 
datagram size instead of complaining `message too long', this option
needs the patch 9a_Sockopt_Get-Max-Packet-Size.diff (submitted yesterday).

Iperf has a new `packet-oriented' mode which allows to run DCCP in 
constant-bit-rate mode, exactly as in UDP. The TCP-like, byte-blast mode
is supported as before. Descriptions are on that page.
