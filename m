From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 May 2008 09:07:20 +0000
Subject: Re: [PATCH] DCCP: Fix to handle short sequence numbers packet
Message-Id: <20080522090720.GA4827@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4834EA23.3070309@cn.fujitsu.com>
In-Reply-To: <4834EA23.3070309@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> But DCCP has some mistake to handle short sequence numbers packet, now  
> it drop packet only if P.type is Data, Ack, or DataAck and P.X = 0.
>
> This patch fixed this problem.
>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

I also put this patch into the test tree, as long as it is not in mainline.
