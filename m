From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 04 Dec 2006 01:55:51 +0000
Subject: Re: [BUG] CCID3 performance
Message-Id: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/1/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> Folks,
>
> With 2.6.19rc6 plus the patches from
> http://wand.net.nz/~iam4/dccp/patches/ it works fine. (The only
> significant patch here is tx_qlen - all the rest should have no
> impact).
>
> So here are the stats using iperf:
> Test                                             2.6.19rc6+ian
> 2.6.20-acme20
> Direct connect                                87 Mbits             36 Mbits
> Through a Linux router (1.2 ms rtt)    36 Mbit               200 kbits
> (yes that is correct!)
> Through netem (100 ms rtt, 5% loss)  130 kbits           116 kbits (OK)
>
I've been trying to track this down to any individual patch and I'm
going crazy! With my code (2.6.19rc6+my patches) now I'm getting the
same bad numbers as for 2.6.20-acme20

This is bizarre and means that there is something in there very fickle
and intermittent...

That means I also owe a big apology to everybody for casting
dispersion on their code.

I'm giving up for today I think as my head hurts!!

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
