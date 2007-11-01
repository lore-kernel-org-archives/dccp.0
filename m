From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 01 Nov 2007 12:22:49 +0000
Subject: Re: [PATCH 3/25] Adjustments of the ccid-4 copyright and kernel
Message-Id: <20071101122248.GB19989@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710312021.53536.leandroal@gmail.com>
In-Reply-To: <200710312021.53536.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Oct 31, 2007 at 20:21:53 -0300, Leandro wrote:
> [CCID-4] Adjustments of the ccid-4 copyright and kernel module authors
> 
> Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
> Signed-off-by: Tommi Saviranta <wnd@iki.fi>
> 
> Index: leandro.new/net/dccp/ccids/ccid4.h
> =================================> --- leandro.new.orig/net/dccp/ccids/ccid4.h
> +++ leandro.new/net/dccp/ccids/ccid4.h
> @@ -1,14 +1,26 @@
>  #ifndef _DCCP_CCID4_H_
>  #define _DCCP_CCID4_H_
>  /*
> - *  net/dccp/ccids/ccid4.h
> + *  net/dccp/ccids/ccid4.c

Is this intentional? ccid2.h and ccid3.h both have ccidX.h.

