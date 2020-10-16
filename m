From: Jakub Kicinski <kuba@kernel.org>
Date: Fri, 16 Oct 2020 22:30:16 +0000
Subject: Re: [PATCH 1/2] dccp: ccid: move timers to struct dccp_sock
Message-Id: <20201016153016.04bffc1e@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-2-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-2-kleber.souza@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, 13 Oct 2020 19:18:48 +0200 Kleber Sacilotto de Souza wrote:
> From: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> 
> When dccps_hc_tx_ccid is freed, ccid timers may still trigger. The reason
> del_timer_sync can't be used is because this relies on keeping a reference
> to struct sock. But as we keep a pointer to dccps_hc_tx_ccid and free that
> during disconnect, the timer should really belong to struct dccp_sock.
> 
> This addresses CVE-2020-16119.
> 
> Fixes: 839a6094140a (net: dccp: Convert timers to use timer_setup())
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>

I've been mulling over this fix.

The layering violation really doesn't sit well.

We're reusing the timer object. What if we are really unlucky, the
fires and gets blocked by a cosmic ray just as it's about to try to
lock the socket, then user manages to reconnect, and timer starts
again. Potentially with a different CCID algo altogether?

Is disconnect ever called under the BH lock?  Maybe plumb a bool
argument through to ccid*_hc_tx_exit() and do a sk_stop_timer_sync()
when called from disconnect()?

Or do refcounting on ccid_priv so that the timer holds both the socket
and the priv?
