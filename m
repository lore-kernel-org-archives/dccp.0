From: <Nicolas.Ferre@microchip.com>
Date: Thu, 10 Sep 2020 08:24:21 +0000
Subject: Re: [trivial PATCH] treewide: Convert switch/case fallthrough; to break;
Message-Id: <c2929349-ca60-486d-3cad-a83321587c5f@microchip.com>
List-Id: <dccp.vger.kernel.org>
References: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
In-Reply-To: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Joe,

Please drop this chunk: it's a successive controller version number 
which are all backward compatible with "fallthrough" on each case so 
removing from this last one makes it inconsistent.

In sort: NACK for atmel-mci.

Best regards,
   Nicolas


On 09/09/2020 at 22:06, Joe Perches wrote:
> diff --git a/drivers/mmc/host/atmel-mci.c b/drivers/mmc/host/atmel-mci.c
> index 444bd3a0a922..8324312e4f42 100644
> --- a/drivers/mmc/host/atmel-mci.c
> +++ b/drivers/mmc/host/atmel-mci.c
> @@ -2435,7 +2435,7 @@ static void atmci_get_cap(struct atmel_mci *host)
>          case 0x100:
>                  host->caps.has_bad_data_ordering = 0;
>                  host->caps.need_reset_after_xfer = 0;
> -               fallthrough;
> +               break;
>          case 0x0:
>                  break;
>          default:


-- 
Nicolas Ferre
