From: Burak Gorkemli <burakgmail-dccp@yahoo.com>
Date: Wed, 12 Dec 2007 14:45:54 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <15735.52980.qm@web30010.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>
> Here is my list of points, hoping that the others will add theirs, too:
> 
>  * would be good to have a standardised set of scripts,
> for
> 
 comparison/benchmarking
> 
>  * the built-in VoIP module only works for UDP -- is it possible
> to
> 
 port this to DCCP?
>  
>  * as per previous email, more complex traffic scenarios would be
> good,
> 
 in particular
>    - switching on/off background traffic at times to
> observe
> 
 TCP/flow-friendliness
>    - running multiple DCCP flows in parallel and at overlapping times 
>

The scenario that I mostly use is limiting the bandwidth with a middlebox running TBF. However, all of the recent trees except 2.6.20final_dccp (2.6.20 patched with Ian's modifications) that I have tested fail to achieve acceptable transfer rates. Test setup is as follows, unless otherwise mentioned:

- Two Linux boxes are connected through another Linux box (middlebox) running netem. The boxes at the edge are identical machines with P4 2.4GHz and 512MB memory. Middlebox is a P4 2.6GHz with 512MB memory.
- TBF is used to limit the bandwidth. TBF buffer is set as 10000 bytes and the limit is 30000 bytes.
- 20ms constant delay is present in both sender->receiver and receiver->sender directions.
- iperf in bytestream mode is used in these tests, and the streaming duration is set as 60 seconds.
- DCCPv4 is used in the tests.


Below are the results of the two different trees:

Kernel: 2.6.20final_dccp (2.6.20 davem tree with Ian's patches - except for the best_packet_next patch. The patches applied are not the latest ones which are updated at 2nd of December, but the ones before the latest.)
Results:
Bottleneck00Kbps, tx_qlen=5:    0.0-60.3 sec    6.86 MBytes   955 Kbits/sec



Bottleneck 00Kbps, tx_qlen=5:    0.0-60.1 sec    13.3 MBytes   1.86 Kbits/sec




BottleneckP00Kbps, tx_qlen=5:    0.0-60.0 sec    27.2 MBytes   3.80 Kbits/sec




Bottleneck000Kbps, limitP000bytes, tx_qlen=5:    0.0-60.0 sec    43.6 MBytes   6.09 Kbits/sec






Kernel: 2.6.24-rc4 (Gerrit's latest tree):
Results (Bottleneck bandwidth, tx_qlen:    iperf server output):
Bottleneck00Kbps, tx_qlen=5:    0.0-168.2 sec    107 KBytes   5.21 Kbits/sec


Bottleneck00Kbps, tx_qlen=0:    0.0-147.8 sec    157 KBytes   8.71 Kbits/sec


Bottleneck 00Kbps, tx_qlen=5:    0.0-89.0 sec    138 KBytes   12.7 Kbits/sec


Bottleneck 00Kbps, tx_qlen=0:    0.0-103.9 sec    203 KBytes   16.0 Kbits/sec


BottleneckP00Kbps, tx_qlen=5:    0.0-66.6 sec    222 KBytes   27.3 Kbits/sec


BottleneckP00Kbps, tx_qlen=0:    0.0-100.2 sec    314 KBytes   25.7 Kbits/sec


Bottleneck000Kbps, tx_qlen=5:    0.0-60.5 sec    1.30 MBytes   181 Kbits/sec


Bottleneck000Kbps, tx_qlen=0:    0.0-65.3 sec    922 KBytes   116 Kbits/sec

While writing this mail, I noticed that Ian has updated his patch set for 2.6.20. I will use this set and repeat the tests this week, hopefully. Moreover, I also tested Ian's patches for other trees (2.6.22 and 2.6.24) but the results were not as good as 2.6.20final_dccp results, if I remember correctly. I can go over them again, if necessary.


> 
> Gerrit   
> -

Burak



