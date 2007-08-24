From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Aug 2007 15:37:53 +0000
Subject: Test Tree Regression Tests
Message-Id: <200708241637.53767@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have done a few tests with delay / loss, in particular the instances specified on 
	http://linux-net.osdl.org/index.php/DCCP_Testing#Regression_testing

Without delay/loss, I get line speed (92.0 Mbps from e100 to e1000, 95.0 Mbps from e1000 to e100).

This was for t seconds; the following test runs were all done for t = 20 seconds.


1) Light Loss (40 msec RTT, 1 %loss)
------------------------------------
	* calculated value: 3.20 Mbps (s = 1424)
	* Test runs: 3.21 Mbps, 3.19 Mbps, 3.18 Mbps


2) Heavy Loss (150 msec RTT, 10 %loss)
--------------------------------------
	* calculated value: 134.34 Kbps
	* test runs: 
		(a) with a FIFO length of 1000 at the bridge
		        209 Kbps, 186 Kbps, 182 Kbps
		(b) with a FIFO length of 10,000 at the bridge
			197 Kbps, 176 Kbps, 134 Kbps

(I am using different FIFO length since I know from experience that otherwise the bridge
can also incur loss.)
		

=> I actually have a question here, regarding the variability. 
    I am setting the same loss in either direction, i.e. on the bridge I do

	tc qdisc add dev eth0 root netem delay 75ms loss 10%
	tc qdisc add dev eth1 root netem delay 75ms loss 10%
   
    I note that on http://linux-net.osdl.org/index.php/DCCP_Testing#Network_emulation_setup
    different loss values for forward/return are used. Has anyone further experience with this?
    I wonder if feedback loss has heavier implications than forward loss?
		


Script I used: http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/tfrc_test.tc 
