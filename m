From: Jakub Kicinski <kuba@kernel.org>
Date: Thu, 16 Jul 2020 19:56:08 +0000
Subject: Re: [PATCH net-next v4] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <20200716125608.33a0589b@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20200712225520.269542-1-richard_siegfried@systemli.org>
In-Reply-To: <20200712225520.269542-1-richard_siegfried@systemli.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, 13 Jul 2020 00:55:20 +0200 Richard Sailer wrote:
> This adds support for the SIOCOUTQ IOCTL to get the send buffer fill
> of a DCCP socket, like UDP and TCP sockets already have.
> 
> Regarding the used data field: DCCP uses per packet sequence numbers,
> not per byte, so sequence numbers can't be used like in TCP. sk_wmem_queued
> is not used by DCCP and always 0, even in test on highly congested paths.
> Therefore this uses sk_wmem_alloc like in UDP.
> 
> Signed-off-by: Richard Sailer <richard_siegfried@systemli.org>

Sorry for the late review

> diff --git a/Documentation/networking/dccp.rst b/Documentation/networking/dccp.rst
> index dde16be044562..74659da107f6b 100644
> --- a/Documentation/networking/dccp.rst
> +++ b/Documentation/networking/dccp.rst
> @@ -192,6 +192,8 @@ FIONREAD
>  	Works as in udp(7): returns in the ``int`` argument pointer the size of
>  	the next pending datagram in bytes, or 0 when no datagram is pending.
>  
> +SIOCOUTQ
> +  Returns the number of data bytes in the local send queue.

FIONREAD uses tabs for indentation, it seems like a good idea to
document the size of the argument (i.e. "returns in the ``int`` ...").

>  Other tunables
>  =======
> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
> index c13b6609474b6..dab74e8a8a69b 100644
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -375,6 +375,14 @@ int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg)
>  		goto out;
>  
>  	switch (cmd) {
> +	case SIOCOUTQ: {
> +		/* Using sk_wmem_alloc here because sk_wmem_queued is not used by DCCP and
> +		 * always 0, comparably to UDP.
> +		 */
> +		int amount = sk_wmem_alloc_get(sk);
> +		rc = put_user(amount, (int __user *)arg);

checkpatch warns:

WARNING: Missing a blank line after declarations
#48: FILE: net/dccp/proto.c:383:
+		int amount = sk_wmem_alloc_get(sk);
+		rc = put_user(amount, (int __user *)arg);

Could you please address that, and better still move the declaration of
"int amount" up to the function level and avoid the funky bracket around
the case statement altogether?

> +	}
> +		break;
>  	case SIOCINQ: {
>  		struct sk_buff *skb;
>  		unsigned long amount = 0;
