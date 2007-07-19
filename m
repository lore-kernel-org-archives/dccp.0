From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 19 Jul 2007 23:41:26 +0000
Subject: Re: iperf
Message-Id: <5640c7e00707191641w789034f5maded5b308f20934a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/20/07, Patrick <patrick.andrieux@gmail.com> wrote:
> Hi,
>
> Quick question on iperf and kernel 2.6.22 (official and exp DCCP tree).
> I use 2 computers + 1 netembox in between
> Here are iperf cmd lines I use :
> on dccpServer : # iperf -s -Xdccp -l1424
> on dccpClient : # iperf -c dccpServer -Xdccp -l1424 -t30
>
> On 2.6.22 kernel:
> Without netem rate control, iperf result is about 95.0 Mbits/sec
> With netem rate control at 1024Kbits/sec, iperf result could be
> 10Kbits/sec or 30Kbits/sec...
>
> On 2.6.20 with Ian's patches:
> Without netem rate control, iperf result is about 95.0 Mbits/sec
> With netem rate control at 1024Kbits/sec, iperf result is about 950Kbits/sec.
>
> netem cmd lines: (I also tried with delay and loss turned on)
> tc qdisc add dev eth0 root handle 1:0 tbf rate 1024kbit buffer 10000 limit 30000
> tc qdisc add dev eth1 root handle 1:0 tbf rate 1024kbit buffer 10000 limit 30000
>
> Is anyone has a such low rate on 2.6.22 kernel? do you know why?
>
> regards,
> Patrick.
>

Question - what do you get on an unpatched 2.6.20 kernel? I think this
is my patches making it work well but want to verify that it's not
just something breaking between 2.6.20 and 2.6.22.

I'll try and replicate this later.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
