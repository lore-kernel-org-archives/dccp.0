From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 31 Oct 2016 18:00:54 +0000
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Message-Id: <CAM_iQpWs1YvrZQF8JTzWR0u0V4t4f3b71WStStGWqDd7agHN_w@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
In-Reply-To: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sun, Oct 30, 2016 at 6:20 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2016-10-30 at 05:41 +0100, Andrey Konovalov wrote:
>> Sorry, the warning is still there.
>>
>> I'm not sure adding sched_annotate_sleep() does anything, since it's
>> defined as (in case CONFIG_DEBUG_ATOMIC_SLEEP is not set):
>> # define sched_annotate_sleep() do { } while (0)
>
> Thanks again for testing.
>
> But you do have CONFIG_DEBUG_ATOMIC_SLEEP set, which triggers a check in
> __might_sleep() :
>
> WARN_ONCE(current->state != TASK_RUNNING && current->task_state_change,
>
> Relevant commit is 00845eb968ead28007338b2bb852b8beef816583
> ("sched: don't cause task state changes in nested sleep debugging")
>
> Another relevant commit was 26cabd31259ba43f68026ce3f62b78094124333f
> ("sched, net: Clean up sk_wait_event() vs. might_sleep()")
>
> Before release_sock() could process the backlog in process context, only
> lock_sock() could trigger the issue, so my fix at that time was commit
> cb7cf8a33ff73cf638481d1edf883d8968f934f8 ("inet: Clean up
> inet_csk_wait_for_connect() vs. might_sleep()")
>

Thanks for the context, but isn't the original warning reported by Andrey is
from inet_wait_for_connect()? You seem only patch some dccp function
which is why it is still there?

It should be the following, no?


diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9648c97..bbd8159 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -544,6 +544,7 @@ static long inet_wait_for_connect(struct sock *sk,
long timeo, int writebias)
         * without closing the socket.
         */
        while ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
+               sched_annotate_sleep();
                release_sock(sk);
                timeo = schedule_timeout(timeo);
                lock_sock(sk);
