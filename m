From: David Miller <davem@davemloft.net>
Date: Sat, 23 Jun 2018 01:47:20 +0000
Subject: Re: [PATCH net 0/2] net: dccp: fixes around rx_tstamp_last_feedback
Message-Id: <20180623.104720.1186761997356792898.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20180622134415.104266-1-edumazet@google.com>
In-Reply-To: <20180622134415.104266-1-edumazet@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 22 Jun 2018 06:44:13 -0700

> This patch series fix some issues with rx_tstamp_last_feedback.
> 
> - Switch to monotonic clock.
> - Avoid potential overflows on fast hosts/networks.

Series applied and queued up for -stable.

Thank you.
