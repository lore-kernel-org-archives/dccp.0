From: David Miller <davem@davemloft.net>
Date: Fri, 14 Dec 2012 18:16:54 +0000
Subject: Re: [PATCH v2] inet: Fix kmemleak in tcp_v4/6_syn_recv_sock and dccp_v4/6_request_recv_sock
Message-Id: <20121214.131654.1860514296150221967.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1355494078-7880-1-git-send-email-christoph.paasch@uclouvain.be>
In-Reply-To: <1355494078-7880-1-git-send-email-christoph.paasch@uclouvain.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Fri, 14 Dec 2012 15:07:58 +0100

> If in either of the above functions inet_csk_route_child_sock() or
> __inet_inherit_port() fails, the newsk will not be freed:
 ...
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied and queued up for -stable.
