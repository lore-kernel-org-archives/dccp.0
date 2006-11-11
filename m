From: Joshua Brindle <jbrindle@tresys.com>
Date: Sat, 11 Nov 2006 15:56:33 +0000
Subject: Re: [PATCH RFC] SELinux support for DCCP
Message-Id: <4555F2B1.6050003@tresys.com>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

James Morris wrote:
> The kernel patch is included below, please review.
>
> Signed-off-by: James Morris <jmorris@namei.org>
>   
> +#define CONTEXT__TRANSLATE                        0x00000001UL
> +#define CONTEXT__CONTAINS                         0x00000002UL
>   
> +   S_(SECCLASS_CONTEXT, CONTEXT__TRANSLATE, "translate")
> +   S_(SECCLASS_CONTEXT, CONTEXT__CONTAINS, "contains")
>   
> +    S_("context")
>   
> +#define SECCLASS_CONTEXT                                 59
>   

oops?

