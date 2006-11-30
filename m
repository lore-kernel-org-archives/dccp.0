From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Nov 2006 22:44:11 +0000
Subject: Re: [BUG] CCID3 performance is f**ked
Message-Id: <5640c7e00611301444y4d8a8487r470a7609b2b66bfa@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
In-Reply-To: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/1/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> > Can I suggest that people test CCID3 on a range of loss, rtt
> > combinations please? CCID3 has proven time after time to be very
> > sensitive....
>
> As I told you, I'm preparing a more comprehensive test environment
> here, just being sidetracked by some problems using net-2.6.20 on a
> parisc64 machine.
>
> - Arnaldo
>
Yes you did say that which is good. I will try and document my test
procedures on OSDL Wiki at some stage. Basically I just use netem on
Linux router though and compare performance to
http://wand.net.nz/~perry/max_download.php (remember to set MSS to
packet size used in iperf) - results within about 20% are normal.

Local machines I get 80+Mbits (on 100 Mbits card) and 30-40 Mbits on
machine through router.

If you get a funny test result then rerun as random netem loss can
cause random results at times. I usually run iperf for 10-20 seconds
(10 is the default)

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
