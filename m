From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Tue, 17 Jul 2007 19:13:44 +0000
Subject: iperf
Message-Id: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

   I'm using iperf to make some DCCP tests and I'd like to know if it
is possible to make iperf client (with -c option) transmit packets
during certain duration and measure the throughput each x seconds.
I've used -t 3 (for instance) option, but iperf just connect, send
packets, show the results and finish its job. I'd like to continuous
take instant throughput for each x seconds, how to do this?

[]s
Leandro.
