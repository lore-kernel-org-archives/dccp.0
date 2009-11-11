From: Golam Sarwar <Golam.Sarwar@nicta.com.au>
Date: Wed, 11 Nov 2009 11:29:12 +0000
Subject: Problem with CCID2 in 2.6.31
Message-Id: <2F0FD8E3A35DD543A61AC85B4B69254B2D6974E3F2@atp-mbx1.in.nicta.com.au>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

**(Please disregard my last email without a subject line)

Dear List,

I have upgraded my test machines to 2.6.31 (released on 9-11-2009) experimental DCCP tree. With CCID2, My problem is - I can not send enough data even though both my test machines are connected to 10Mbit/s LAN. While with CCID3, for the same 2 machines, with exact same configuration, I can transfer data properly without being limited by anything.

The following is my iperf output for CCID2:
=======================[  4]  0.0- 1.0 sec  31.9 KBytes   261 Kbits/sec
[  4]  1.0- 2.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  2.0- 3.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  3.0- 4.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  4.0- 5.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  5.0- 6.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  6.0- 7.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  7.0- 8.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  8.0- 9.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  9.0-10.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4] 10.0-11.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4] 11.0-12.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4] 12.0-13.0 sec  2.77 KBytes  22.7 Kbits/sec
[  4]  0.0-13.0 sec  65.2 KBytes  41.0 Kbits/sec
=======================
The following is my iperf output for CCID3:
=======================[  4] local 203.143.170.102 port 5001 connected with 203.143.170.200 port 56657
[  4]  0.0- 1.0 sec  11549 KBytes  94606 Kbits/sec
[  4]  1.0- 2.0 sec  11586 KBytes  94913 Kbits/sec
[  4]  2.0- 3.0 sec  11568 KBytes  94765 Kbits/sec
[  4]  3.0- 4.0 sec  11583 KBytes  94890 Kbits/sec
[  4]  4.0- 5.0 sec  11585 KBytes  94901 Kbits/sec
[  4]  5.0- 6.0 sec  11576 KBytes  94833 Kbits/sec
[  4]  6.0- 7.0 sec  11579 KBytes  94856 Kbits/sec
[  4]  7.0- 8.0 sec  11583 KBytes  94890 Kbits/sec
[  4]  8.0- 9.0 sec  11586 KBytes  94913 Kbits/sec
[  4]  9.0-10.0 sec  11564 KBytes  94731 Kbits/sec
[  4]  0.0-10.0 sec  115801 KBytes  94810 Kbits/sec
=======================
I am using the following /proc entries to switch between CCID2 and CCID3:
=======================sysctl -w net.dccp.default.seq_window000
sysctl -w net.dccp.default.rx_ccid=2
sysctl -w net.dccp.default.tx_ccid=2
=======================
I have double checked this issue with an older kernel (2.6.25-rc8) on the same two machines and I don't get this problem with CCID2. The following is the iperf receiving end output from one of the two 2.6.25-rc8 machines:

=======================[  4]  0.0- 1.0 sec  11507 KBytes  94265 Kbits/sec
[  4]  1.0- 2.0 sec  11508 KBytes  94277 Kbits/sec
[  4]  2.0- 3.0 sec  11507 KBytes  94265 Kbits/sec
[  4]  3.0- 4.0 sec  11507 KBytes  94265 Kbits/sec
[  4]  4.0- 5.0 sec  11508 KBytes  94277 Kbits/sec
[  4]  5.0- 6.0 sec  11507 KBytes  94265 Kbits/sec
[  4]  6.0- 7.0 sec  11508 KBytes  94277 Kbits/sec
[  4]  7.0- 8.0 sec  11507 KBytes  94265 Kbits/sec
[  4]  8.0- 9.0 sec  11507 KBytes  94265 Kbits/sec
[  4]  9.0-10.0 sec  11508 KBytes  94277 Kbits/sec
[  4]  0.0-10.0 sec  115132 KBytes  94269 Kbits/sec
=======================

Regards,
Golam Sarwar (Babil)
