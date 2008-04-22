From: David Miller <davem@davemloft.net>
Date: Tue, 22 Apr 2008 02:45:26 +0000
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Message-Id: <20080421.194526.101135578.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080421.023503.242108516.davem@davemloft.net>
In-Reply-To: <20080421.023503.242108516.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Tue, 22 Apr 2008 11:40:42 +0900 (JST)

> In article <20080421.142857.234288906.davem@davemloft.net> (at Mon, 21 Apr 2008 14:28:57 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > Thanks for reviewing, patch applied.
> 
> Sorry I have just realized set_normalized_timespec() (used in timespec_sub())
> is not exported, and link will fail because of it...
> 
> What should I/we do?  Send the patch to LKML as well?

I'll apply and push this change, thank you.
