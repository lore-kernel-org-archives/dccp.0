From: David Miller <davem@davemloft.net>
Date: Wed, 01 Oct 2014 22:34:37 +0000
Subject: Re: [PATCH 1/1 linux-next] net/dccp/proto.c: add __init to dccp_mib_init
Message-Id: <20141001.183437.1387283987407270369.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1412138883-2476-1-git-send-email-fabf@skynet.be>
In-Reply-To: <1412138883-2476-1-git-send-email-fabf@skynet.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  1 Oct 2014 06:48:03 +0200

> dccp_mib_init is only called by __init dccp_init in same module.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
