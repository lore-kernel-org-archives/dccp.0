From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Aug 2007 07:17:42 +0000
Subject: Re: Test Tree Regression Tests
Message-Id: <200708280817.43206@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708241637.53767@strip-the-willow>
In-Reply-To: <200708241637.53767@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > (I am using different FIFO length since I know from experience that otherwise the bridge
|  > can also incur loss.)
|  >
|  Can you post scripts for altering the fifo length? Is that equivalent
|  to the following for rate-limited? (from test page)
|  /sbin/tc qdisc add dev lan0 root handle 1:0 netem delay $1ms
|  /sbin/tc qdisc add dev lan1 root handle 1:0 netem delay $1ms
|  /sbin/tc qdisc add dev lan0 parent 1:1 handle 10: tbf rate $2kbit
|  buffer 10000 limit 30000

It is comparable but not equivalent, since in the above you are using a TBF which will change the nature
of the traffic. I use the following (with qlen000):

  	tc qdisc add dev eth0 root handle 1:0 netem delay ${delay}ms
        tc qdisc add dev eth0 parent 1:1 pfifo limit ${qlen}
 
(The same configuration is used on both interfaces.) I found that merely adding the tx qlen of the NIC
(via `ip link set ...') does not do much, and that especially if either the delay is slightly longer
or the difference in traffic is drastic (e.g. 100Mbps link with a TBF rate of 1 Mbps), a longer FIFO 
length is needed to avoid packets being dropped at the traffic shaper.
Plus, one gets all the nice statistics about queue drops and requeued etc. 


|  >     I note that on http://linux-net.osdl.org/index.php/DCCP_Testing#Network_emulation_setup
|  >     different loss values for forward/return are used. Has anyone further experience with this?
|  >     I wonder if feedback loss has heavier implications than forward loss?
|  >
|  
|  The reason for me putting zero % loss on return path is that we are
|  testing unidirectional flows. As such I wanted all feedback to come
|  back and if we lost feedback packets it would increase variability. We
|  should test loss of feedback packets for protocol reasons but not so
|  much for performance testing.
Ah - I see, so this means that for performance testing I'd have to use:?

        tc qdisc add dev eth0 root netem delay 75ms loss 10%      # the forward path
        tc qdisc add dev eth1 root netem delay 75ms		  # reverse path (no feedback loss)

Maybe we should add a line on the OSDL page, it is something that had slightly confused me.


|  Your webserver seems to be down.... No pages on
|  http://www.erg.abdn.ac.uk/ work at present.
Occasional, short downtime is possible, but usually the webserver runs all the time. It is ok again.
