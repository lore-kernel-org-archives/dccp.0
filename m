From: David Miller <davem@davemloft.net>
Date: Thu, 31 Aug 2017 18:44:08 +0000
Subject: Re: [PATCH] net: dccp: Add handling of IPV6_PKTOPTIONS to dccp_v6_do_rcv()
Message-Id: <20170831.114408.429602044118453235.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20170830090435.58406d1b@dev>
In-Reply-To: <20170830090435.58406d1b@dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Andrii <tulup@mail.ru>
Date: Thu, 31 Aug 2017 08:28:01 +0300

> Add handling of IPV6_PKTOPTIONS to dccp_v6_do_rcv() in
> net/dccp/ipv6.c, similar
> to the handling in net/ipv6/tcp_ipv6.c
> 
> Signed-off-by: Andrii Vladyka <tulup@mail.ru>

Applied.
