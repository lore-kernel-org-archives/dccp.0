From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Mar 2017 04:40:54 +0000
Subject: Re: [PATCH net] dccp/tcp: fix routing redirect race
Message-Id: <1489034454.28631.21.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
References: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com>
In-Reply-To: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, 2017-03-09 at 14:42 +1100, Jonathan Maxwell wrote:
> Sorry let me resend in plain text mode.
> 
> On Thu, Mar 9, 2017 at 1:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2017-03-09 at 12:15 +1100, Jon Maxwell wrote:
> >> We have seen a few incidents lately where a dst_enty has been freed
> >> with a dangling TCP socket reference (sk->sk_dst_cache) pointing to that
> >> dst_entry. If the conditions/timings are right a crash then ensues when the
> >> freed dst_entry is referenced later on. A Common crashing back trace is:
> >
> > Very nice catch !
> >
> 
> Thanks Eric.
> 
> > Don't we have a similar issue for IPv6 ?
> >
> >
> 
> Good point.
> 
> We checked and as far as we can tell IPv6 does not invalidate the route.
> So it should be safer.

Simply doing :

__sk_dst_check(sk, np->dst_cookie);

is racy, even before calling dst->ops->redirect(dst, sk, skb);

(if socket is owned by user)



