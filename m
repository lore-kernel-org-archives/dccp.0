From: David Miller <davem@davemloft.net>
Date: Mon, 18 Jun 2007 02:17:19 +0000
Subject: Re: [PATCH 0/4]: DCCP ktime_t initial work
Message-Id: <20070617.191719.18280743.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070618020540.GA4226@ghostprotocols.net>
In-Reply-To: <20070618020540.GA4226@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 17 Jun 2007 23:05:40 -0300

> 	Please consider pulling from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.23
> 
> 	I briefed Thomas Gleixner about the new ktime_us_delta and
> ktime_add_us functions and he is OK with having them added to ktime.h.
> 
> 	More work on this are going on Gerrit Renker's experimental tree
> that I plan to review and cherry pick soon, thanks Gerrit for all the
> hard work!

Looks good, pulled and pushed back out, thanks a lot!
