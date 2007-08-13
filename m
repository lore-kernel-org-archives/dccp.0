From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 13 Aug 2007 09:19:54 +0000
Subject: Re: [PATCH] [148/2many] MAINTAINERS - DCCP PROTOCOL
Message-Id: <5640c7e00708130219i463817bbu2b4c3e299b778cf4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <46bff97c.9avHEM3TinhF1DrA%joe@perches.com>
In-Reply-To: <46bff97c.9avHEM3TinhF1DrA%joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/13/07, joe@perches.com <joe@perches.com> wrote:
> Add file pattern to MAINTAINER entry
>
> Signed-off-by: Joe Perches <joe@perches.com>
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 7f54480..c786066 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1434,6 +1434,8 @@ M:        acme@ghostprotocols.net
>  L:     dccp@vger.kernel.org
>  W:     http://linux-net.osdl.org/index.php/DCCP
>  S:     Maintained
> +F:     include/linux/dccp.h
> +F:     net/dccp/
>
Provided this patch series goes in then we need to add this in as well
as part of DCCP subsystem:
F:  include/linux/tfrc.h

Once this is done, and series goes in then:
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
