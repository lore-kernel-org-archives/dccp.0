From: David Miller <davem@davemloft.net>
Date: Thu, 13 Jul 2017 16:24:44 +0000
Subject: Re: [PATCH] dccp: make const array error_code static
Message-Id: <20170713.092444.2018465341570344249.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20170713112224.31667-1-colin.king@canonical.com>
In-Reply-To: <20170713112224.31667-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 13 Jul 2017 12:22:24 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate array error_code on the stack but make it static. Makes
> the object code smaller by almost 250 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>   10366	    983	      0	  11349	   2c55	net/dccp/input.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>   10161	   1039	      0	  11200	   2bc0	net/dccp/input.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
