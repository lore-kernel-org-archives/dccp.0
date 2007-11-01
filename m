From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 01 Nov 2007 11:49:01 +0000
Subject: Re: [PATCH 7/25] Initial lib for sharing common code between
Message-Id: <20071101114901.GA19989@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.24513.leandroal@gmail.com>
In-Reply-To: <200710312130.24513.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Oct 31, 2007 at 21:30:24 -0300, Leandro wrote:
> [CCID-3/4 lib] Initial lib for sharing common code between ccid-3/ccid-4
> 
> The lib is called tfrc_ccids.o

> Index: leandro.new/net/dccp/ccids/lib/Makefile
> =================================> --- leandro.new.orig/net/dccp/ccids/lib/Makefile
> +++ leandro.new/net/dccp/ccids/lib/Makefile
> @@ -1,4 +1,5 @@
>  obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
>  
>  dccp_tfrc_lib-y := tfrc_module.o    tfrc_equation.o \
> -                   packet_history.o loss_interval.o
> +                   packet_history.o loss_interval.o \
> +		   tfrc_ccids.o

Whitespace police hits! I don't remember Documentation/CodingStyle
mentioning anything about whitespaces in Makefiles. Nevertheless,
packet_history.o is indented here with spaces, tfrc_ccids.o with
tabulators, I think we should stick to just one kind of whitespace.

> -                   packet_history.o loss_interval.o
> +                   packet_history.o loss_interval.o \
> +                   tfrc_ccids.o

