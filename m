From: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
Date: Thu, 15 Oct 2020 10:53:58 +0000
Subject: Re: [PATCH 1/2] dccp: ccid: move timers to struct dccp_sock
Message-Id: <20201015105358.GA367246@mussarela>
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-2-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-2-kleber.souza@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Oct 14, 2020 at 08:43:22PM -0700, Jakub Kicinski wrote:
> On Tue, 13 Oct 2020 19:18:48 +0200 Kleber Sacilotto de Souza wrote:
> > From: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> > 
> > When dccps_hc_tx_ccid is freed, ccid timers may still trigger. The reason
> > del_timer_sync can't be used is because this relies on keeping a reference
> > to struct sock. But as we keep a pointer to dccps_hc_tx_ccid and free that
> > during disconnect, the timer should really belong to struct dccp_sock.
> > 
> > This addresses CVE-2020-16119.
> > 
> > Fixes: 839a6094140a (net: dccp: Convert timers to use timer_setup())
> 
> Presumably you chose this commit because the fix won't apply beyond it?
> But it really fixes 2677d2067731 (dccp: don't free.. right?

Well, it should also fix cases where dccps_hc_tx_ccid{,_private} has been freed
right after the timer is stopped.

So, we could add:
Fixes: 2a91aa396739 ([DCCP] CCID2: Initial CCID2 (TCP-Like) implementation)
Fixes: 7c657876b63c ([DCCP]: Initial implementation)

But I wouldn't say that this fixes 2677d2067731, unless there is argument to
say that it fixes it because it claimed to fix what is being fixed here. But
even the code that it removed was supposed to be stopping the timer, so how
could it ever fix what it was claiming to fix?

Thanks.
Cascardo.

> 
> > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> > Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
