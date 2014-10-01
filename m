From: David Miller <davem@davemloft.net>
Date: Wed, 01 Oct 2014 22:34:45 +0000
Subject: Re: [PATCH 1/1 linux-next] net/dccp/ccid.c: add __init to ccid_activate
Message-Id: <20141001.183445.1800881550207439817.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1412139126-3794-1-git-send-email-fabf@skynet.be>
In-Reply-To: <1412139126-3794-1-git-send-email-fabf@skynet.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  1 Oct 2014 06:52:06 +0200

> ccid_activate is only called by __init ccid_initialize_builtins in same module.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
