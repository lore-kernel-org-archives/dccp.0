From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Aug 2007 02:52:14 +0000
Subject: Re: Test Tree Regression Tests
Message-Id: <5640c7e00708271952g1abbd6f5xff0756c0facbe56f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200708241637.53767@strip-the-willow>
In-Reply-To: <200708241637.53767@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/25/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> 2) Heavy Loss (150 msec RTT, 10 %loss)
> --------------------------------------
>         * calculated value: 134.34 Kbps
>         * test runs:
>                 (a) with a FIFO length of 1000 at the bridge
>                         209 Kbps, 186 Kbps, 182 Kbps
>                 (b) with a FIFO length of 10,000 at the bridge
>                         197 Kbps, 176 Kbps, 134 Kbps
>
> (I am using different FIFO length since I know from experience that otherwise the bridge
> can also incur loss.)
>
Can you post scripts for altering the fifo length? Is that equivalent
to the following for rate-limited? (from test page)
/sbin/tc qdisc add dev lan0 root handle 1:0 netem delay $1ms
/sbin/tc qdisc add dev lan1 root handle 1:0 netem delay $1ms
/sbin/tc qdisc add dev lan0 parent 1:1 handle 10: tbf rate $2kbit
buffer 10000 limit 30000

>
> => I actually have a question here, regarding the variability.
>     I am setting the same loss in either direction, i.e. on the bridge I do
>
>         tc qdisc add dev eth0 root netem delay 75ms loss 10%
>         tc qdisc add dev eth1 root netem delay 75ms loss 10%
>
>     I note that on http://linux-net.osdl.org/index.php/DCCP_Testing#Network_emulation_setup
>     different loss values for forward/return are used. Has anyone further experience with this?
>     I wonder if feedback loss has heavier implications than forward loss?
>

The reason for me putting zero % loss on return path is that we are
testing unidirectional flows. As such I wanted all feedback to come
back and if we lost feedback packets it would increase variability. We
should test loss of feedback packets for protocol reasons but not so
much for performance testing.
>
>
> Script I used: http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/tfrc_test.tc

Your webserver seems to be down.... No pages on
http://www.erg.abdn.ac.uk/ work at present.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
