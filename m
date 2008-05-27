From: David Miller <davem@davemloft.net>
Date: Tue, 27 May 2008 13:22:52 +0000
Subject: Re: [PATCH 1/7] [DCCP]: Fix to handle short sequence numbers
Message-Id: <20080527.062252.108813459.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1211877167-10995-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1211877167-10995-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:41 +0100

> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> RFC4340 said:
>   8.5.  Pseudocode
>        ...
>        If P.type is not Data, Ack, or DataAck and P.X = 0 (the packet
>              has short sequence numbers), drop packet and return
> 
> But DCCP has some mistake to handle short sequence numbers packet, now
> it drop packet only if P.type is Data, Ack, or DataAck and P.X = 0.
> 
> This patch fixed this problem.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

As it is a bug fix I've applied this to net-2.6, thanks.
