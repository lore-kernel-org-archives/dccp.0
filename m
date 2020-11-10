From: Jakub Kicinski <kuba@kernel.org>
Date: Tue, 10 Nov 2020 16:16:55 +0000
Subject: Re: [PATCH 1/2] dccp: ccid: move timers to struct dccp_sock
Message-Id: <20201110081655.29cbcd34@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-2-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-2-kleber.souza@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, 10 Nov 2020 08:19:32 -0300 Thadeu Lima de Souza Cascardo wrote:
> Yeah, I agree with your initial email. The patch I submitted for that fix needs
> rework, which is what I tried and failed so far. I need to get back to some
> testing of my latest fix and find out what needs fixing there.
> 
> But I am also saying that simply doing a del_timer_sync on disconnect paths
> won't do, because there are non-disconnect paths where there is a CCID that we
> will remove and replace and that will still trigger a timer UAF.
> 
> So I have been working on a fix that involves a refcnt on ccid itself. But I
> want to test that it really fixes the problem and I have spent most of the time
> finding out a way to trigger the timer in a race with the disconnect path.

Sounds good, thanks a lot for working on this!

> And that same test has showed me that this timer UAF will happen regardless of
> commit 2677d20677314101293e6da0094ede7b5526d2b1, which led me into stating that
> reverting it should be done in any case.
> 
> I think I can find some time this week to work a little further on the fix for
> the time UAF.
