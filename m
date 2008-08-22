From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 22 Aug 2008 01:44:36 +0000
Subject: Re: [PATCH] dccp: Reponsed with Reset when packet is received with
Message-Id: <48AE1A04.5040504@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <48AB7147.2010003@cn.fujitsu.com>
In-Reply-To: <48AB7147.2010003@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> Thanks a lot for this patch -- I will integrate it into the test tree
> and upload the updated version (include Acked-by's) tomorrow morning.
>
>   
>> RFC4340 said that if a packet is received with invalid option(such as Mandatory
>> Option as the last byte of the option list),
>>     
> While looking at dccp_parse_options, it seems to me that this case
> (Mandatory as the last option, or a one or more OK-options followed by
>  a faulty one) may use the wrong Reset code, since the `rc' variable
> is assigned different values while looping through the header options.
> Did you notice such a case?
>
> In any case, I will be adding 
>
> --- a/net/dccp/options.c
> +++ b/net/dccp/options.c
> @@ -243,6 +243,7 @@ ignore_option:
>  	}
>  
>  	/* mandatory was the last byte in option list -> reset connection */
> +	rc = DCCP_RESET_CODE_OPTION_ERROR;
>  	if (mandatory)
>  		goto out_invalid_option;
>   

This patch seems not correctly. The patch may look like this :
    while (opt_ptr != opt_end) {         
         rc = DCCP_RESET_CODE_OPTION_ERROR;
    ...
    }

rc may be override by process change option, if is OK, rc become 0. So 
the code "goto out_invalid_option;" in while statements will get reset 
code 0.

Regards
Wei Yongjun

