From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 30 Oct 2016 13:20:01 +0000
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Message-Id: <1477833601.7065.297.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
In-Reply-To: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sun, 2016-10-30 at 05:41 +0100, Andrey Konovalov wrote:
> Sorry, the warning is still there.
> 
> I'm not sure adding sched_annotate_sleep() does anything, since it's
> defined as (in case CONFIG_DEBUG_ATOMIC_SLEEP is not set):
> # define sched_annotate_sleep() do { } while (0)

Thanks again for testing.

But you do have CONFIG_DEBUG_ATOMIC_SLEEP set, which triggers a check in
__might_sleep() :

WARN_ONCE(current->state != TASK_RUNNING && current->task_state_change,

Relevant commit is 00845eb968ead28007338b2bb852b8beef816583
("sched: don't cause task state changes in nested sleep debugging")

Another relevant commit was 26cabd31259ba43f68026ce3f62b78094124333f
("sched, net: Clean up sk_wait_event() vs. might_sleep()") 

Before release_sock() could process the backlog in process context, only
lock_sock() could trigger the issue, so my fix at that time was commit
cb7cf8a33ff73cf638481d1edf883d8968f934f8 ("inet: Clean up
inet_csk_wait_for_connect() vs. might_sleep()")

I guess we need something else now, because the following :

static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
{
        DEFINE_WAIT(wait);
        long remaining;

        prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
        sk->sk_write_pending++;
        release_sock(sk);
	...


can now process the socket backlog in process context from
release_sock(), so all GFP_KERNEL allocations might barf because of
TASK_INTERRUPTIBLE being used at that point.

sk_wait_event() probably also needs a fix.

Peter, any idea how this can be done ?

Thanks !

