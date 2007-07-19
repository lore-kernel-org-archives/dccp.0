From: Patrick <patrick.andrieux@gmail.com>
Date: Thu, 19 Jul 2007 12:42:13 +0000
Subject: Re: iperf
Message-Id: <fca78b970707190542g506388f1hfae19dc9483b5fd4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

Quick question on iperf and kernel 2.6.22 (official and exp DCCP tree).
I use 2 computers + 1 netembox in between
Here are iperf cmd lines I use :
on dccpServer : # iperf -s -Xdccp -l1424
on dccpClient : # iperf -c dccpServer -Xdccp -l1424 -t30

On 2.6.22 kernel:
Without netem rate control, iperf result is about 95.0 Mbits/sec
With netem rate control at 1024Kbits/sec, iperf result could be
10Kbits/sec or 30Kbits/sec...

On 2.6.20 with Ian's patches:
Without netem rate control, iperf result is about 95.0 Mbits/sec
With netem rate control at 1024Kbits/sec, iperf result is about 950Kbits/sec.

netem cmd lines: (I also tried with delay and loss turned on)
tc qdisc add dev eth0 root handle 1:0 tbf rate 1024kbit buffer 10000 limit 30000
tc qdisc add dev eth1 root handle 1:0 tbf rate 1024kbit buffer 10000 limit 30000

Is anyone has a such low rate on 2.6.22 kernel? do you know why?

regards,
Patrick.


On 17/07/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 7/18/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> > Hi,
> >
> >    I'm using iperf to make some DCCP tests and I'd like to know if it
> > is possible to make iperf client (with -c option) transmit packets
> > during certain duration and measure the throughput each x seconds.
> > I've used -t 3 (for instance) option, but iperf just connect, send
> > packets, show the results and finish its job. I'd like to continuous
> > take instant throughput for each x seconds, how to do this?
> >
> > []s
> > Leandro.
>
> From iperf --help
>   -i, --interval  #        seconds between periodic bandwidth reports
>
> I use this quite a bit and works perfectly. I've also modified iperf
> to run continuously if you need that capability - available from my
> web page.
>
> Ian
> --
> Web: http://wand.net.nz/~iam4/
> Blog: http://iansblog.jandi.co.nz
> WAND Network Research Group
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
