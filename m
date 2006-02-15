From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Wed, 15 Feb 2006 11:57:47 +0000
Subject: Re: [PATCH] 1/1 dccp: transmit buffering
Message-Id: <43F3173B.1090308@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
In-Reply-To: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian McDonald wrote:
> On 2/7/06, Ian McDonald <imcdnzl@gmail.com> wrote:
>>> See the comments below, I guess we don't need yet another lock :-)
>> Will look at some more about locks as time permits - we take
>> possession of our house today :-)
> 
> Still bit short of time but tested some more and found it clashed with
> feature negotiation so will need more work :-( One of the problems is
> with the code stopping the retransmit timer in feature negotiation.
> Removing that fixes it for standard test cases but it then fails with
> delay of 50 ms and 10% loss using netem where it worked without
> feature negotiation for me. Might be bottom half locking perhaps -
> haven't tested changes to that yet.

Andrea, can you take a look at this one?

>> The reason for this is to allow sending of queued packets when user
>> application says close...
>>
>>> sk_reset_timer() please, so that we make sure we have a reference count
>>> for the sock as its going to be on a timer
>> As I read the timer source code if the timer returns do I have to do a
>> sock_put (I am guessing so as I don't see how it would happen
>> elsewise).
> 
> Are you able to answer this?

Yes, you have to do a sock_put at the end of the timer routine, if
you restart the timer with sk_reset_timer it'll grab another refcount,
so the one done at first firing the timer will be dropped by the
sock_put at the end of the timer routine.

>>> sk_stop_timer please, to drop the refcount we grabbed with sk_reset_timer()
>>> elsewhere.
>>>
>> The thing with sk_stop_timer is that it doesn't check if the timer
>> routine is in use which would mean that we can have problems (I hit
>> this in testing). I presume the best way is to create a
>> sk_stop_timer_sync rather than use generic timer...
> 
> Any comments on this anyone as this is how I intend to code it...

Well, it checks, look at its usage of mod_timer to see if the timer was
pending and if not drop the lock, i.e. no refcount leakage here, if you
are worried about races that is why we use the timer routine under
bh_lock_sock()/bh_release_sock(), look at ccid3_hc_tx_no_feedback_timer.

Or is it some other worry you have? can you elaborate? If you need
mod_timer return forwarded to the sk_reset_user() user we can do it if
needed.

- Arnaldo

