From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Nov 2006 23:30:29 +0000
Subject: Re: [PATCH 6/6]: Tidy up unused structures
Message-Id: <20061123233029.GA3369@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.46843@strip-the-willow>
In-Reply-To: <200611211545.46843@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Nov 21, 2006 at 03:45:46PM +0000, Gerrit Renker wrote:
> [CCID 3]: Tidy up unused structures
> 
> This removes and cleans up unused variables and structures 
> which have become unnecessary following the introduction of
> the EWMA patch to automatically track the CCID 3 receiver/sender
> packet sizes `s'.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  include/linux/dccp.h   |    3 ---
>  net/dccp/ccids/ccid3.h |    4 ----
>  net/dccp/proto.c       |    7 -------
>  3 files changed, 14 deletions(-)
> 
> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -200,7 +200,6 @@ struct dccp_so_feat {
>  };
>  
>  /* DCCP socket options */
> -#define DCCP_SOCKOPT_PACKET_SIZE	1

Suggestion: just add a comment stating that DCCP_SOCKOPT_PACKET_SIZE is
deprecated and ...

>  #define DCCP_SOCKOPT_SERVICE		2

<SNIP>
  
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -469,9 +469,6 @@ static int do_dccp_setsockopt(struct soc
>  
>  	lock_sock(sk);
>  	switch (optname) {
> -	case DCCP_SOCKOPT_PACKET_SIZE:
> -		dp->dccps_packet_size = val;
> -		break;

... printk(KERN_WARNING "setsockopt(PACKET_SIZE) is deprecated, "
			"fix your app\n");

Its not like there are tons of apps using this interface, but I think
that this is what we have to do in these cases.

- Arnaldo
