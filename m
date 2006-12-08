From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 08 Dec 2006 13:59:16 +0000
Subject: CCID 3 starts to rock!
Message-Id: <200612081359.16989@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Just compiled the latest DaveM kernel on top of which the stack of submitted
patches are applied. And see what I got:

doom: ~#  iperf -Xdccp -l1424 -s -t20
------------------------------------------------------------
Server listening on DCCP port 5001
 (default)
------------------------------------------------------------
[  4] local 139.133.209.65 port 5001 connected with 139.133.209.75 port 57297
[  4]  0.0-20.0 sec  1.23 GBytes    527 Mbits/sec


I am not saying that this is due to the patches, but it is encouraging enough
to improve the code so that it climbs up to the 940 Mbits/sec or so that TCP does.
So, let's keep at this 8-)
