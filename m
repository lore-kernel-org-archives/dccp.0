From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 24 Jan 2007 23:27:01 +0000
Subject: Re: [PATCH 4/7]: Provide function for RTT sampling
Message-Id: <5640c7e00701241527v71343f5bjbdf07a8b286c11ce@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701231541.01730@strip-the-willow>
In-Reply-To: <200701231541.01730@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 24/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  Is 100 microseconds a bit high perhaps? I'm seeing about 250
> |  microseconds on a 100 Mbits LAN and therefore presumably on a 10 Gbits
> |  LAN it could be as low as 2.5 microseconds??
> This is correct, but these are not speeds that CCID 3 can handle. From my
> calculations, the maximum speed is about 12 kilobits/second: the best possible
> t_gran is 1 millisecond; whenever t_ipi < t_gran, then the speed of sending
> packets is no longer controlled by the packet scheduling.
>
OK. I might wade into the debate about packet scheduling later but
won't for now.

-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
