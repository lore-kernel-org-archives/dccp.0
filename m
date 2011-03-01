From: Johan Hovold <jhovold@gmail.com>
Date: Tue, 01 Mar 2011 12:03:27 +0000
Subject: Re: dccp: null-pointer dereference on close
Message-Id: <20110301120327.GA13273@localhost>
List-Id: <dccp.vger.kernel.org>
References: <20110226174505.GB3609@localhost>
In-Reply-To: <20110226174505.GB3609@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Mar 01, 2011 at 06:59:45AM +0100, Gerrit Renker wrote:
> Johan,
> 
> thanks a lot for the detailed description.
> 
> I think I have found the cause of the dccp timewait problem: in the 
> mainline tree there is a path
> 
>  dccp_v4_do_rcv() 
> 	|
> 	| state other than OPEN
> 	v
>  dccp_rcv_state_process()
> 	|
> 	| DCCP_PKT_RESET
> 	v
>  dccp_rcv_reset()
> 	|
> 	v
>  dccp_time_wait()
> 
> In the backtrace dccp_close() had been called, hence dccp_set_state() has
> destroyed inet_csk(sk)->icsk_bind_hash, which then subsequently in the
> misplaced dccp_time_wait() caused the NULL pointer exception.
> 
> I have just checked, this problem seems to not be possible in the test
> tree, since it checks first in dccp_rcv_state_process() if DCCP_CLOSED
> has been entered (if it receives a packet in this state, it sends a 
> Reset with code 3, "No Connection").
> 
> I am attaching the relevant patch from the test tree - would it be possible
> for you to test it with the same setup? (The relevant passage is right in 
> the first hunk, where it tests for state = DCCP_CLOSED).

As expected I do not seem able to trigger the null-pointer exception
with the patch applied to 2.6.38-rc6. The patch does not apply to the
2.6.37 kernel I was using, but only moving to closed-state check does the
trick.
 
> Will submit this patch subsequently also.

May I suggest separating the closed-state-check fix into a patch of
its own which could be marked for stable and more easily backported as
it fixes a pretty severe bug?

Below are the bits that fixed the issue on 2.6.37. Perhaps this along
with a more detailed description of the error, including the panic
message, could serve as the basis for such a patch?

Feel free to add

Reported-and-tested-by: Johan Hovold <jhovold@gmail.com>

Thanks,
Johan


From eda93f93102ad13bc470db63cfd7b0dc27d1e4fa Mon Sep 17 00:00:00 2001
From: Johan Hovold <jhovold@gmail.com>
Date: Tue, 1 Mar 2011 12:13:39 +0100
Subject: [PATCH] net: dccp: fix null-pointer dereference on close

---
 net/dccp/input.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index e424a09..421f42c 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -621,6 +621,9 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		/* Caller (dccp_v4_do_rcv) will send Reset */
 		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
 		return 1;
+	} else if (sk->sk_state = DCCP_CLOSED) {
+		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
+		return 1;
 	}
 
 	if (sk->sk_state != DCCP_REQUESTING && sk->sk_state != DCCP_RESPOND) {
@@ -683,10 +686,6 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	}
 
 	switch (sk->sk_state) {
-	case DCCP_CLOSED:
-		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
-		return 1;
-
 	case DCCP_REQUESTING:
 		queued = dccp_rcv_request_sent_state_process(sk, skb, dh, len);
 		if (queued >= 0)
-- 
1.7.4

