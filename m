From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 19 Jul 2007 23:45:07 +0000
Subject: Re: iperf
Message-Id: <5640c7e00707191645v2deaaf12nc4b3c5e54930f85b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/20/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
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
I still think that DCCP CCID3 should respond gracefully in this
circumstance, not collapse. We have congestion control and we
shouldn't go down to virtually nothing. TCP works fine, older versions
of DCCP work fine. I've got to research what is going on for sure
though. Might be time to use dccp_probe as well and work out what's
going on?

Are others aware of dccp_probe? - this is quite useful for looking at
problems like this.

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

I will try these out - going to play with iperf for a bit now...

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
