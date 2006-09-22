From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 03:22:54 +0000
Subject: Re: [PATCH 2.6.17][Trivial] net/dccp: update references to standards
Message-Id: <5640c7e00609212022p4b9f85a5t93ca9ada4206ad8f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo - this looks good.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

On 9/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Sorry kmail garbled this, clean text below.
>
> - Gerrit
> --
>
> diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
> index 859e335..2c345c0 100644
> --- a/net/dccp/Kconfig
> +++ b/net/dccp/Kconfig
> @@ -4,9 +4,9 @@ menu "DCCP Configuration (EXPERIMENTAL)"
>  config IP_DCCP
>         tristate "The DCCP Protocol (EXPERIMENTAL)"
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
