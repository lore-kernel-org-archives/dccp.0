From: Ian McDonald <imcdnzl@gmail.com>
Date: Mon, 06 Feb 2006 23:04:08 +0000
Subject: Re: [PATCH] 1/1 dccp: transmit buffering
Message-Id: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> See the comments below, I guess we don't need yet another lock :-)

Will look at some more about locks as time permits - we take
possession of our house today :-)
> > @@ -191,7 +192,7 @@ static int dccp_wait_for_ccid(struct soc
> >         while (1) {
> >                 prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
> >
> > -               if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
> > +               if (sk->sk_err)
>
> Humm, have to check this one...

The reason for this is to allow sending of queued packets when user
application says close...

> sk_reset_timer() please, so that we make sure we have a reference count
> for the sock as its going to be on a timer

As I read the timer source code if the timer returns do I have to do a
sock_put (I am guessing so as I don't see how it would happen
elsewise).

> > +       dp->dccps_xmit_lock = SPIN_LOCK_UNLOCKED;
>
> Not needed

I presume you mean because that is the default state? (Provided I
don't get rid of the lock altogether)

> sk_stop_timer please, to drop the refcount we grabbed with sk_reset_timer()
> elsewhere.
>
The thing with sk_stop_timer is that it doesn't check if the timer
routine is in use which would mean that we can have problems (I hit
this in testing). I presume the best way is to create a
sk_stop_timer_sync rather than use generic timer...

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
