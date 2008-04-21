From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 21 Apr 2008 13:48:44 +0000
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Message-Id: <20080421134844.GC12221@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080421.023503.242108516.davem@davemloft.net>
In-Reply-To: <20080421.023503.242108516.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Em Mon, Apr 21, 2008 at 02:35:03AM -0700, David Miller escreveu:
> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Mon, 21 Apr 2008 16:22:27 +0900 (JST)
> 
> > What do_gettimeofday() does is to call getnstimeofday() and
> > to convert the result from timespec{} to timeval{}.
> > We do not always need timeval{} and we can convert timespec{}
> > when we really need (to print).
> > 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> This looks good too, but I'll be polite and wait for any
> DCCP maintainer ACKs :-)

Thanks everybody:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo
