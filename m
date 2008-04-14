From: David Miller <davem@davemloft.net>
Date: Mon, 14 Apr 2008 05:38:56 +0000
Subject: Re: [RFC][PATCH 0/12][NETNS]: Make DCCP protocol minimally work in
Message-Id: <20080413.223856.33881755.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <47FBA7D4.8020708@openvz.org>
In-Reply-To: <47FBA7D4.8020708@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 21:13:56 +0400

> This is the set against current net-2.6.26 David's tree with
> minimal DCCP per-net functionality. It actually includes the
> ctl socket netnsization, proper use of IP routing and socket 
> lookup.
> 
> The dccp is currently flooded with init_net access, rather than
> proper net and it's going to become more of this stuff, so I
> think it's time to pay more attention to it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.26, with Arnaldo's acks.
