From: Andrey Konovalov <andreyknvl@google.com>
Date: Sat, 29 Oct 2016 17:59:53 +0000
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Message-Id: <CAAeHK+x6+CU+1KJNOpnoyyZoqH7_dcrWFVGU1KrJYVwJSzdxPg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
In-Reply-To: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Eric,

Tested with both patches applied, still seeing the warning.

Thanks!

On Sat, Oct 29, 2016 at 7:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-10-29 at 19:06 +0200, Andrey Konovalov wrote:
>> Hi Cong,
>>
>> Tested with your patch, still getting a warning, though it's a little different:
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 1 PID: 3876 at kernel/sched/core.c:7724
>> __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
>> do not call blocking ops when !TASK_RUNNING; state=1 set at
>> [<ffffffff811f5a5c>] prepare_to_wait+0xbc/0x210
>> kernel/sched/wait.c:178
>> Modules linked in:
>
> This looks like the following patch is needed, can you test it ?
> Thanks !
>
> diff --git a/net/dccp/output.c b/net/dccp/output.c
> index b66c84db0766..74d8583a0d52 100644
> --- a/net/dccp/output.c
> +++ b/net/dccp/output.c
> @@ -228,6 +228,7 @@ static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
>
>         remaining = schedule_timeout(delay);
>
> +       sched_annotate_sleep();
>         lock_sock(sk);
>         sk->sk_write_pending--;
>         finish_wait(sk_sleep(sk), &wait);
>
>
>
