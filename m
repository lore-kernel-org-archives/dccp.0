From: Ian McDonald <imcdnzl@gmail.com>
Date: Wed, 15 Feb 2006 01:18:27 +0000
Subject: Re: [PATCH] 1/1 dccp: transmit buffering
Message-Id: <cbec11ac0602141718v15ded75br1496b08e3d26a702@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
In-Reply-To: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/7/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> > See the comments below, I guess we don't need yet another lock :-)
>
> Will look at some more about locks as time permits - we take
> possession of our house today :-)

Still bit short of time but tested some more and found it clashed with
feature negotiation so will need more work :-( One of the problems is
with the code stopping the retransmit timer in feature negotiation.
Removing that fixes it for standard test cases but it then fails with
delay of 50 ms and 10% loss using netem where it worked without
feature negotiation for me. Might be bottom half locking perhaps -
haven't tested changes to that yet.
>
> The reason for this is to allow sending of queued packets when user
> application says close...
>
> > sk_reset_timer() please, so that we make sure we have a reference count
> > for the sock as its going to be on a timer
>
> As I read the timer source code if the timer returns do I have to do a
> sock_put (I am guessing so as I don't see how it would happen
> elsewise).

Are you able to answer this?
>
> > sk_stop_timer please, to drop the refcount we grabbed with sk_reset_timer()
> > elsewhere.
> >
> The thing with sk_stop_timer is that it doesn't check if the timer
> routine is in use which would mean that we can have problems (I hit
> this in testing). I presume the best way is to create a
> sk_stop_timer_sync rather than use generic timer...

Any comments on this anyone as this is how I intend to code it...

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
