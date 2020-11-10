From: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
Date: Tue, 10 Nov 2020 11:19:32 +0000
Subject: Re: [PATCH 1/2] dccp: ccid: move timers to struct dccp_sock
Message-Id: <20201110111932.GS595944@mussarela>
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-2-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-2-kleber.souza@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Nov 09, 2020 at 02:15:53PM -0800, Jakub Kicinski wrote:
> On Mon, 9 Nov 2020 18:31:34 -0300 Thadeu Lima de Souza Cascardo wrote:
> > > Which paths are those (my memory of this code is waning)? I thought
> > > disconnect is only called from the user space side (shutdown syscall).
> > > The only other way to terminate the connection is to close the socket,
> > > which Eric already fixed by postponing the destruction of ccid in that
> > > case.  
> > 
> > dccp_v4_do_rcv -> dccp_rcv_established -> dccp_parse_options ->
> > 	dccp_feat_parse_options -> dccp_feat_handle_nn_established ->
> > 	dccp_feat_activate -> __dccp_feat_activate -> dccp_hdlr_ccid ->
> > 	ccid_hc_tx_delete
> 
> Well, that's not a disconnect path.
> 
> There should be no CCID on a disconnected socket, tho, right? Otherwise
> if we can switch from one active CCID to another then reusing a single
> timer in struct dccp_sock for both is definitely not safe as I
> explained in my initial email.

Yeah, I agree with your initial email. The patch I submitted for that fix needs
rework, which is what I tried and failed so far. I need to get back to some
testing of my latest fix and find out what needs fixing there.

But I am also saying that simply doing a del_timer_sync on disconnect paths
won't do, because there are non-disconnect paths where there is a CCID that we
will remove and replace and that will still trigger a timer UAF.

So I have been working on a fix that involves a refcnt on ccid itself. But I
want to test that it really fixes the problem and I have spent most of the time
finding out a way to trigger the timer in a race with the disconnect path.

And that same test has showed me that this timer UAF will happen regardless of
commit 2677d20677314101293e6da0094ede7b5526d2b1, which led me into stating that
reverting it should be done in any case.

I think I can find some time this week to work a little further on the fix for
the time UAF.

Thanks.
Cascardo.
