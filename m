From: gerrit@erg.abdn.ac.uk
Date: Thu, 20 Jan 2011 11:38:41 +0000
Subject: Re: [PATCH clean-up] dccp: clean up unused DCCP_STATE_MASK
Message-Id: <58207.148.187.160.35.1295523521.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <4D37FC96.9000407@cn.fujitsu.com>
In-Reply-To: <4D37FC96.9000407@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Remove unused DCCP_STATE_MASK macro.
>
>
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -279,8 +279,6 @@ enum dccp_state {
>  	DCCP_MAX_STATES
>  };
>
> -#define DCCP_STATE_MASK 0x1f

