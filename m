From: Johannes Deleu <Johannes.Deleu@intec.ugent.be>
Date: Thu, 22 Jun 2006 12:41:42 +0000
Subject: mail voor linux mailinglist
Message-Id: <449A9006.9030608@intec.ugent.be>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Hi,

for a project, we're interested in using DCCP. As such, I did some 
performance measurements with the latest version of the DCCP 
implementation. To my opinion, they are not really what I expected. 
Could you give some ideas or maybe some information about the current 
status of the implementation (e.g. is packet loss detection planned for 
implementation, when ?) ?

Results of similar tests are also interesting to see if they compare.
For the tests, I used an impairment node (based on linux, which 
introduced some packet loss).

Measurements where performed with the patched iperf on linux-2.6.16.20 
and I came to the following table:

                    TCP                 DCCP-CCID3 (Send/Recv)
No drop       94 Mbps          93.3 Mbps      93.2 Mbps
Drop 1%      83.4 Mbps       93.3 Mbps      92.3 Mbps
Drop 5%      16.6 Mbps       93.3 Mbps      88.6 Mbps
Drop 10%    3.25 Mbps       93.3 Mbps      83.9 Mbps

The transmitter does not detect the packet loss and doesnt slow down, 
instead it keeps sending <CCID option 192 4294967295>.
As CCID3 is TFRC, I expected similar results for TCP and DCCP-CCID3.

When i tried out linux-2.6.17.1 (no packet drop) the receiver seems to 
stop sending feedback packets after a while and the transmitter slows 
down. The receiving process doesnt receive any data (recv doesnt return).

[  3] local 10.0.1.3 port 3743 connected with 10.0.1.1 port 5001
[  3]  0.0- 1.0 sec  11.0 MBytes  92.5 Mbits/sec
[  3]  1.0- 2.0 sec  10.9 MBytes  91.6 Mbits/sec
[  3]  2.0- 3.0 sec  10.9 MBytes  91.6 Mbits/sec
[  3]  3.0- 4.0 sec  10.9 MBytes  91.6 Mbits/sec
[  3]  4.0- 5.0 sec  10.9 MBytes  91.6 Mbits/sec
[  3]  5.0- 6.0 sec  10.9 MBytes  91.6 Mbits/sec
[  3]  6.0- 7.0 sec  6.86 MBytes  57.5 Mbits/sec
[  3]  7.0- 8.0 sec    194 KBytes  1.59 Mbits/sec
[  3]  8.0- 9.0 sec    100 KBytes    819 Kbits/sec
[  3]  9.0-10.0 sec    100 KBytes    819 Kbits/sec
[  3] 10.0-11.0 sec    100 KBytes    819 Kbits/sec
[  3] 11.0-12.0 sec    100 KBytes    819 Kbits/sec
[  3] 12.0-13.0 sec    100 KBytes    819 Kbits/sec

best regards,
Johannes
