From: David Miller <davem@davemloft.net>
Date: Sun, 06 Feb 2011 02:14:24 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <20110205.181424.112605200.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Date: Fri, 04 Feb 2011 09:38:34 +0100

> Could you add a reference to draft?
> 
>> +/* TCP initial congestion window */
>> +#define TCP_INIT_CWND		10
>> +
>> extern struct inet_timewait_death_row tcp_death_row;

Sure, done.

--------------------
tcp: Add reference to initial CWND ietf draft.

Suggested by Alexander Zimmermann

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7118668..adfe6db 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -196,7 +196,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* TCP thin-stream limits */
 #define TCP_THIN_LINEAR_RETRIES 6       /* After 6 linear retries, do exp. backoff */
 
-/* TCP initial congestion window */
+/* TCP initial congestion window as per draft-hkchu-tcpm-initcwnd-01 */
 #define TCP_INIT_CWND		10
 
 extern struct inet_timewait_death_row tcp_death_row;
-- 
1.7.4

