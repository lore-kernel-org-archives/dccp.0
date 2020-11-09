From: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
Date: Mon, 09 Nov 2020 11:48:28 +0000
Subject: Re: [PATCH 1/2] dccp: ccid: move timers to struct dccp_sock
Message-Id: <20201109114828.GP595944@mussarela>
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-2-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-2-kleber.souza@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Oct 16, 2020 at 03:30:16PM -0700, Jakub Kicinski wrote:
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
> > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> > Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
> 
> I've been mulling over this fix.
> 
> The layering violation really doesn't sit well.
> 
> We're reusing the timer object. What if we are really unlucky, the
> fires and gets blocked by a cosmic ray just as it's about to try to
> lock the socket, then user manages to reconnect, and timer starts
> again. Potentially with a different CCID algo altogether?
> 
> Is disconnect ever called under the BH lock?  Maybe plumb a bool
> argument through to ccid*_hc_tx_exit() and do a sk_stop_timer_sync()
> when called from disconnect()?
> 
> Or do refcounting on ccid_priv so that the timer holds both the socket
> and the priv?

Sorry about too late a response. I was on vacation, then came back and spent a
couple of days testing this further, and had to switch to other tasks.

So, while testing this, I had to resort to tricks like having a very small
expire and enqueuing on a different CPU. Then, after some minutes, I hit a UAF.
That's with or without the first of the second patch.

I also tried to refcount ccid instead of the socket, keeping the timer on the
ccid, but that still hit the UAF, and that's when I had to switch tasks. Oh,
and in the meantime, I found one or two other fixes that we should apply, will
send them shortly.

But I would argue that we should apply the revert as it addresses the CVE,
without really regressing the other UAF, as I argued. Does that make sense?

Thank you.
Cascardo.
