From: Steffen Maier <maier@linux.ibm.com>
Date: Thu, 10 Sep 2020 09:18:29 +0000
Subject: Re: [trivial PATCH] treewide: Convert switch/case fallthrough; to break;
Message-Id: <0c66fbe5-c48b-7dc1-f7fe-1498da9cc1a3@linux.ibm.com>
List-Id: <dccp.vger.kernel.org>
References: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
In-Reply-To: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/9/20 10:06 PM, Joe Perches wrote:
> fallthrough to a separate case/default label break; isn't very readable.
> 
> Convert pseudo-keyword fallthrough; statements to a simple break; when
> the next label is case or default and the only statement in the next
> label block is break;
> 
> Found using:
> 
> $ grep-2.5.4 -rP --include=*.[ch] -n "fallthrough;(\s*(case\s+\w+|default)\s*:\s*){1,7}break;" *
> 
> Miscellanea:
> 
> o Move or coalesce a couple label blocks above a default: block.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> Compiled allyesconfig x86-64 only.
> A few files for other arches were not compiled.

>   drivers/s390/scsi/zfcp_fsf.c                              |  2 +-

>   82 files changed, 109 insertions(+), 112 deletions(-)

> diff --git a/drivers/s390/scsi/zfcp_fsf.c b/drivers/s390/scsi/zfcp_fsf.c
> index 140186fe1d1e..2741a07df692 100644
> --- a/drivers/s390/scsi/zfcp_fsf.c
> +++ b/drivers/s390/scsi/zfcp_fsf.c
> @@ -2105,7 +2105,7 @@ static void zfcp_fsf_open_lun_handler(struct zfcp_fsf_req *req)
>   
>   	case FSF_PORT_HANDLE_NOT_VALID:
>   		zfcp_erp_adapter_reopen(adapter, 0, "fsouh_1");
> -		fallthrough;
> +		break;
>   	case FSF_LUN_ALREADY_OPEN:
>   		break;
>   	case FSF_PORT_BOXED:

Acked-by: Steffen Maier <maier@linux.ibm.com> # for zfcp


-- 
Mit freundlichen Gruessen / Kind regards
Steffen Maier

Linux on IBM Z Development

https://www.ibm.com/privacy/us/en/
IBM Deutschland Research & Development GmbH
Vorsitzender des Aufsichtsrats: Matthias Hartmann
Geschaeftsfuehrung: Dirk Wittkopp
Sitz der Gesellschaft: Boeblingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
