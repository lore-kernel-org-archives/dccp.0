From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Oct 2007 15:43:39 +0000
Subject: Re: systemtap networking tapsets was: Re: [RFC]: field name
Message-Id: <20071024154339.GA21383@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20071022163144.GA15773@ghostprotocols.net>
In-Reply-To: <20071022163144.GA15773@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Oct 24, 2007 at 02:35:42PM +0100, Gerrit Renker escreveu:
> Quoting Arnaldo Carvalho de Melo:
> |  > I think that dccpprobe.c is the wrong name ... it should really be called ccid3_probe.c ...
> |  > I have been working on printing entries for CCID2, since in ccid2.c there is no probe support,
> |  > and instead ccid2_pr_debug is used for the same purpose all over the place.
> |  
> |  Indeed, lemme try converting it right now...
> |  
> This is how far I came (only for info, applies only on test tree):

Cool, but what I meant to say was that I was going to try and convert
dccpprobe to be a systemtap script, and this is how far I went, forgot
about x_calc, something fishy there, but take a look at the
dccp_ccid3_probe.stp and its output. The full sources for the tapsets
used (for things like ccid3_hc_tx_sk_rtt(), etc) are at:

http://oops.ghostprotocols.net:81/acme/nettaps.tar.bz2

Still a bit hackish, as we don't expose the ccids header files in
include/net/ for systemtap to use and I tried this on a kernel packaged
as an RPM (kernel-debuginfo, etc), perhaps something to consider
changing. But I used include/linux/tfrc.h, that is exposed and had what
I want.

Ah, and this was over gigabit ethernet, over wi-fi it gets to a crawl
after a while, have to check with your experimental tree, probably you
already fixed this issue.

[root@mica nettaps]# cat dccp_ccid3_probe.stp
#!/usr/bin/stap

global filter_dport = 5001
global rtts
global x_calcs
global ipis

probe dccp_user_out = module("dccp").function("dccp_sendmsg")
{
        dport = inet_sk_dport($sk)
        x_calc = ccid3_hc_tx_sk_x_calc($sk)
        rtt = ccid3_hc_tx_sk_rtt($sk)
        ipi = ccid3_hc_tx_sk_ipi($sk)
}

probe dccp_user_out
{
        if (dport != filter_dport)
                next

        rtts <<< rtt
        x_calcs <<< x_calc
        ipis <<< ipi
}

probe end
{
        printf("rtt: count: %d, min: %d, max: %d, avg: %d\n",
               @count(rtts), @min(rtts), @max(rtts), @avg(rtts))
        print(@hist_linear(rtts, 0, 1000, 20))

        printf("x_calc: count: %d, min: %d, max: %d, avg: %d\n",
               @count(x_calcs), @min(x_calcs), @max(x_calcs), @avg(x_calcs))
        print(@hist_linear(x_calcs, 0, 100000, 2000))

        printf("ipi: count: %d, min: %d, max: %d, avg: %d\n",
               @count(ipis), @min(ipis), @max(ipis), @avg(ipis))
        print(@hist_linear(ipis, 0, 600, 10))
}
[root@mica nettaps]#

[root@mica nettaps]# stap -I tapset/ dccp_ccid3_probe.stp # to finish it press control+C
rtt: count: 38746, min: 0, max: 390, avg: 286
value |-------------------------------------------------- count
    0 |                                                       1
   20 |                                                       0
   40 |                                                       0
   60 |                                                       0
   80 |                                                       0
  100 |                                                       0
  120 |                                                       0
  140 |                                                       0
  160 |                                                      17
  180 |                                                      19
  200 |                                                      21
  220 |@                                                    248
  240 |@@@@@@@@@@@@@@@@@@@@@@@@                            5510
  260 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       10143
  280 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  11290
  300 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@            9095
  320 |@@@@@@                                              1476
  340 |@@                                                   463
  360 |@                                                    370
  380 |                                                      93
  400 |                                                       0
  420 |                                                       0

x_calc: count: 38746, min: 0, max: 0, avg: 0
value |-------------------------------------------------- count
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  38746
 2000 |                                                       0
 4000 |                                                       0

ipi: count: 38746, min: 0, max: 7473, avg: 162
value |-------------------------------------------------- count
    0 |                                                      1
   10 |@@@@                                                654
   20 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  7255
   30 |@@@@@@@@@@@@@@@@@@@                                2876
   40 |@@@@@@@@@@@@@@@@@@@@@@                             3232
   50 |@@@@@@@@@@@@@@@@@@@@@@@@@                          3678
   60 |@@@@@@@@@@@@@@@@@@@                                2775
   70 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@                       4188
   80 |@@@@@@@@@@@@@@                                     2186
   90 |@@@@@@@@@@@@@                                      1986
  100 |@@@@@@                                              940
  110 |@@@@@                                               813
  120 |@@@@@@@@@@                                         1579
  130 |@@@@@                                               738
  140 |@                                                   226
  150 |@@@@@@@@                                           1235
  160 |@@                                                  399
  170 |@@@                                                 452
  180 |                                                      0
  190 |@                                                   289
  200 |                                                      0
  210 |                                                    116
  220 |                                                      0
  230 |@@                                                  311
  240 |                                                      0
  250 |@@                                                  414
  260 |                                                      0
  270 |                                                    119
  280 |                                                      0
  290 |                                                      0
  300 |@@@@@@@@                                           1184
  310 |@@                                                  412
  320 |                                                      0
  330 |                                                      0
  340 |                                                      0
  350 |                                                      0
  360 |                                                      0
  370 |                                                      0
  380 |                                                      0
  390 |                                                      0
  400 |                                                      0
  410 |                                                      0
  420 |                                                      0
  430 |                                                      0
  440 |                                                      0
  450 |                                                      0
  460 |                                                      0
  470 |                                                      0
  480 |                                                      0
  490 |                                                      0
  500 |                                                      0
  510 |                                                      0
  520 |                                                      0
  530 |                                                      0
  540 |                                                      0
  550 |                                                      0
  560 |                                                      0
  570 |                                                      0
  580 |                                                      0
  590 |@@@@                                                688

[root@mica nettaps]#
