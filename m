From: Patrick <patrick.andrieux@gmail.com>
Date: Thu, 19 Jul 2007 16:57:39 +0000
Subject: Re: iperf
Message-Id: <fca78b970707190957k47990be8k40e9f4071d57d361@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Applying only patch #1 doesn't work... patch #2 correct the error.
PerfSocket.cpp: In function 'void MakeSocket(thread_Settings*)':
PerfSocket.cpp:89: error: 'IPPROTO_UDPLITE' was not declared in this scope
make[2]: *** [PerfSocket.o] Error 1
make[2]: Leaving directory `/root/iperf-2.0.2/src'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/root/iperf-2.0.2'
make: *** [all] Error 2

It could be good to not have 2 iperf dccp patched version, one Ian
patched, one Gerrit patched ?

This way gives me the same results.
Without control rate, it works at the maximun rate (1Mbps, 5Mbps, or 10Mbps).
Using netem as middle box limiting at 1024 Kbits/sec, iperf result is
still not what I expected... it goes from 15 Kbits/sec to 60Kbits/sec.

Patrick.


On 19/07/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Patrick:
> |  Hi,
> |
> |  Quick question on iperf and kernel 2.6.22 (official and exp DCCP tree).
> |  I use 2 computers + 1 netembox in between
> |  Here are iperf cmd lines I use :
> |  on dccpServer : # iperf -s -Xdccp -l1424
> |  on dccpClient : # iperf -c dccpServer -Xdccp -l1424 -t30
>
> This iperf variant only sends at full/maximum speed, i.e. it will try aggressively
> to stuff your link, until it is forced to slow down by the kernel. This generates
> a lot of other problems - such as increase in delay, queue overflow etc.
>
> I haven't done bandwidth tests during the last days, but if you are doing such tests
> can you please compare with the constant-bitrate variant of iperf:
>
>  * use original source
>    http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/iperf-2.0.2.tar.gz
>  * only needs patch #1 from
>    http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/patches/
>
>  * then try iteratively with the -b switch to increase the bandwidth, i.e.
>     iperf -c dccpServer -l1424  -d -b1m         # 1Mbps CBR DCCP
>     iperf -c dccpServer -l1424  -d -b5m         # 5Mbps
>     iperf -c dccpServer -l1424  -d -b10m        # 10Mbps
>
> Do you get a higher speed this way? If yes, then the low speeds are likely due to
> queue overflow, otherwise there is another reason. There have been a lot of changes
> in the netdev kernel, the test tree has not been changed.
>
> |
> |  On 2.6.22 kernel:
> |  Without netem rate control, iperf result is about 95.0 Mbits/sec
> |  With netem rate control at 1024Kbits/sec, iperf result could be
> |  10Kbits/sec or 30Kbits/sec...
> |
> |  On 2.6.20 with Ian's patches:
> |  Without netem rate control, iperf result is about 95.0 Mbits/sec
> |  With netem rate control at 1024Kbits/sec, iperf result is about 950Kbits/sec.
> |
> |  netem cmd lines: (I also tried with delay and loss turned on)
> |  tc qdisc add dev eth0 root handle 1:0 tbf rate 1024kbit buffer 10000 limit 30000
> |  tc qdisc add dev eth1 root handle 1:0 tbf rate 1024kbit buffer 10000 limit 30000
> |
> |  Is anyone has a such low rate on 2.6.22 kernel? do you know why?
> |
> |  regards,
> |  Patrick.
> |
> |
> |  On 17/07/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> |  > On 7/18/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> |  > > Hi,
> |  > >
> |  > >    I'm using iperf to make some DCCP tests and I'd like to know if it
> |  > > is possible to make iperf client (with -c option) transmit packets
> |  > > during certain duration and measure the throughput each x seconds.
> |  > > I've used -t 3 (for instance) option, but iperf just connect, send
> |  > > packets, show the results and finish its job. I'd like to continuous
> |  > > take instant throughput for each x seconds, how to do this?
> |  > >
> |  > > []s
> |  > > Leandro.
> |  >
> |  > From iperf --help
> |  >   -i, --interval  #        seconds between periodic bandwidth reports
> |  >
> |  > I use this quite a bit and works perfectly. I've also modified iperf
> |  > to run continuously if you need that capability - available from my
> |  > web page.
> |  >
> |  > Ian
> |  > --
> |  > Web: http://wand.net.nz/~iam4/
> |  > Blog: http://iansblog.jandi.co.nz
> |  > WAND Network Research Group
> |  > -
> |  > To unsubscribe from this list: send the line "unsubscribe dccp" in
> |  > the body of a message to majordomo@vger.kernel.org
> |  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> |  >
> |  -
> |  To unsubscribe from this list: send the line "unsubscribe dccp" in
> |  the body of a message to majordomo@vger.kernel.org
> |  More majordomo info at  http://vger.kernel.org/majordomo-info.html
> |
> |
>


-- 
-------
Patrick ANDRIEUX
email : patrick.andrieux@gmail.com
