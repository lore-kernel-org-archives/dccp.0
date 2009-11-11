From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Nov 2009 11:48:47 +0000
Subject: Re: CCID-2 performance
Message-Id: <20091111114846.GA7370@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Golam,

can you please check whether the branch you used from the test tree
was 'master' or 'dccp' (via 'git branch')?

I have checked the figures below against a test here - I get similar
figures (in the order of several 100 Kbps) when using the 'master'
branch, but on the 'dccp' branch the results are (iperf 20sec runs):
 * CCID-2:    399 Mbps
 * CCID-3:    511 Mbps
 * TCP/cubic: 726 Mbps	

CCID-2 is indeed lagging behind, it is not perfect yet, but it is
a factor of 1000 faster than the top 182 kbps experienced when
using the 'master' branch.

If you are experiencing these results on the 'dccp' branch of the
test tree, the next step should be to check whether any loss occurs.

You can look at the 'ssthresh' values and the way cwnd grows when
using dccp_probe 

Another thing that may help would be to enable the debugging output.
This needs to be enabled at compile time and at runtime:

$ echo 1 > /sys/module/dccp/parameters/ccid2_debug

Gerrit

Quoting Golam Sarwar:
| I have upgraded my test machines to 2.6.31 (released on 9-11-2009)
| experimental DCCP tree. With CCID2, My problem is - I can not send enough
| data even though both my test machines are connected to 10Mbit/s LAN. While
| with CCID3, for the same 2 machines, with exact same configuration, I can
| transfer data properly without being limited by anything.  |
| The following is my iperf output for CCID2:

| =======================| [  4]  0.0- 1.0 sec  31.9 KBytes   261 Kbits/sec
| [  4]  1.0- 2.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  2.0- 3.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  3.0- 4.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  4.0- 5.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  5.0- 6.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  6.0- 7.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  7.0- 8.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  8.0- 9.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  9.0-10.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4] 10.0-11.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4] 11.0-12.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4] 12.0-13.0 sec  2.77 KBytes  22.7 Kbits/sec
| [  4]  0.0-13.0 sec  65.2 KBytes  41.0 Kbits/sec
| =======================| 
| The following is my iperf output for CCID3:
| =======================| [  4] local 203.143.170.102 port 5001 connected with 203.143.170.200 port 56657
| [  4]  0.0- 1.0 sec  11549 KBytes  94606 Kbits/sec
| [  4]  1.0- 2.0 sec  11586 KBytes  94913 Kbits/sec
| [  4]  2.0- 3.0 sec  11568 KBytes  94765 Kbits/sec
| [  4]  3.0- 4.0 sec  11583 KBytes  94890 Kbits/sec
| [  4]  4.0- 5.0 sec  11585 KBytes  94901 Kbits/sec
| [  4]  5.0- 6.0 sec  11576 KBytes  94833 Kbits/sec
| [  4]  6.0- 7.0 sec  11579 KBytes  94856 Kbits/sec
| [  4]  7.0- 8.0 sec  11583 KBytes  94890 Kbits/sec
| [  4]  8.0- 9.0 sec  11586 KBytes  94913 Kbits/sec
| [  4]  9.0-10.0 sec  11564 KBytes  94731 Kbits/sec
| [  4]  0.0-10.0 sec  115801 KBytes  94810 Kbits/sec
| =======================| 
| I am using the following /proc entries to switch between CCID2 and CCID3:
| =======================| sysctl -w net.dccp.default.seq_window000
| sysctl -w net.dccp.default.rx_ccid=2
| sysctl -w net.dccp.default.tx_ccid=2
| =======================| 

| I have double checked this issue with an older kernel (2.6.25-rc8) on the
| same two machines and I don't get this problem with CCID2. The following is
| the iperf receiving end output from one of the two 2.6.25-rc8 machines: |
| =======================| [  4]  0.0- 1.0 sec  11507 KBytes  94265 Kbits/sec
| [  4]  1.0- 2.0 sec  11508 KBytes  94277 Kbits/sec
| [  4]  2.0- 3.0 sec  11507 KBytes  94265 Kbits/sec
| [  4]  3.0- 4.0 sec  11507 KBytes  94265 Kbits/sec
| [  4]  4.0- 5.0 sec  11508 KBytes  94277 Kbits/sec
| [  4]  5.0- 6.0 sec  11507 KBytes  94265 Kbits/sec
| [  4]  6.0- 7.0 sec  11508 KBytes  94277 Kbits/sec
| [  4]  7.0- 8.0 sec  11507 KBytes  94265 Kbits/sec
| [  4]  8.0- 9.0 sec  11507 KBytes  94265 Kbits/sec
| [  4]  9.0-10.0 sec  11508 KBytes  94277 Kbits/sec
| [  4]  0.0-10.0 sec  115132 KBytes  94269 Kbits/sec
| =======================