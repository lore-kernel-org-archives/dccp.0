From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 17 Jul 2007 20:18:24 +0000
Subject: Re: iperf
Message-Id: <5640c7e00707171318g60f184b8t8319103690ca2c6d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/18/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> Hi,
>
>    I'm using iperf to make some DCCP tests and I'd like to know if it
> is possible to make iperf client (with -c option) transmit packets
> during certain duration and measure the throughput each x seconds.
> I've used -t 3 (for instance) option, but iperf just connect, send
> packets, show the results and finish its job. I'd like to continuous
> take instant throughput for each x seconds, how to do this?
>
> []s
> Leandro.

From iperf --help
  -i, --interval  #        seconds between periodic bandwidth reports

I use this quite a bit and works perfectly. I've also modified iperf
to run continuously if you need that capability - available from my
web page.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
