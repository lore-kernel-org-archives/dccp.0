From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 21 Feb 2006 12:09:23 +0000
Subject: Re: [PATCH] 1/1 dccp: transmit buffering
Message-Id: <39e6f6c70602210409r7a731362gae3571328b6fd2e5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
In-Reply-To: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/20/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> Arnaldo, (or anybody else)
>
> I can get it working with the extra lock but not without... Comments
> inline and at the end. Help much appreciated!
>
>
> > Please leave the "extern"
> >
> Yep!
>
> > I guess we don't need this lock, but instead use bh_lock_sock, check if
> > there are users, look at ccid3_hc_tx_no_feedback_timer & ccid2_hc_tx_rto_expire
> > (I left a comment even having fixed the problem, duh will fix).
>
> I'm not sure what you mean by users here. Users of what? Can you explain

Look at lock_sock(), release_sock(), bh_lock_sock(), bh_release_sock() and
at sk_receive_skb and you'll see what I mean :-)

> > sk_reset_timer() please, so that we make sure we have a reference count
> > for the sock as its going to be on a timer
> >
> Will tidyup once get other problems sorted...
>
> > No need for the {}, just one statement
>
> Understand. Lazy when removing debugging...
>
> > sk_eat_skb()  later?
> >
> It would be sk_eat_skb in dccp_write_xmit for two reasons:
> 1) sk_eat_skb alters receive queue. This is write
> 2) Existing xmit doesn't seem to do anything like this. To me it looks
> like the lower level does the kfree_skb...

Scrap that suggestion, brainfart :-\

> >
> > > +       dp->dccps_xmit_lock = SPIN_LOCK_UNLOCKED;
> >
> > Not needed
>
> Understand - will remove
>
> Now I have attached two patches. acme1.diff is slightly tidied up
> version of original patch and works with normal testing and netem
> testing.
>
> acme2.diff is an attempt to get rid of spinlock and use sock_lock as I
> didn't think I needed bh_sock_lock as not receiving packets as that is
> seemed aimed at that (stopping the interrupt driver trashing receive
> queues...)

I'll try to take a look later today, now have to visit a customer...

- Arnaldo
