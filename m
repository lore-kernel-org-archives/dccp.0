From: Tommi Saviranta <wnd@iki.fi>
Date: Fri, 09 Nov 2007 21:11:27 +0000
Subject: Re: [PATCH 5/25] Enforces a minimum interval of 10 milliseconds as
Message-Id: <20071109211127.GC666@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.12981.leandroal@gmail.com>
In-Reply-To: <200710312130.12981.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Nov 08, 2007 at 11:18:30 +0000, Gerrit Renker wrote:
> Maybe the code would be clearer to read this way:
> 
> 	hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
> 					     hctx->ccid4hctx_x));
> 	if (hctx->ccid4hctx_t_ipi <  MIN_SEND_RATE)
> 		hctx->ccid4hctx_t_ipi = MIN_SEND_RATE;

Yes, it would. I was going to ask whether one of them would be
considered more effective, but I then realised this is probably one of
those cases where you should write readable code and let the compiler to
worry about the rest.

