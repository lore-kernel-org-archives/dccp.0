From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 29 Oct 2016 18:05:28 +0000
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Message-Id: <1477764328.7065.284.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
In-Reply-To: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sat, 2016-10-29 at 19:59 +0200, Andrey Konovalov wrote:
> Hi Eric,
> 
> Tested with both patches applied, still seeing the warning.
> 
> Thanks!

Arg, sorry, this was at the wrong place.

Thanks for testing !

diff --git a/net/dccp/output.c b/net/dccp/output.c
index b66c84db0766..2548edff86ff 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -224,6 +224,11 @@ static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
 
 	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	sk->sk_write_pending++;
+
+	/* release_sock()/lock_sock() will process socket backlog
+	 * from process context. Be prepared to sleep !
+	 */
+	sched_annotate_sleep();
 	release_sock(sk);
 
 	remaining = schedule_timeout(delay);


