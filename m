From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 01 Nov 2007 12:58:59 +0000
Subject: Re: [PATCH 24/25] Final adjustments to probe.c to use tfrc_ccids
Message-Id: <20071101125859.GO19989@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710312132.08440.leandroal@gmail.com>
In-Reply-To: <200710312132.08440.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Oct 31, 2007 at 21:32:08 -0300, Leandro wrote:
> [DCCP] Final adjustments to probe.c to use ccid34_lib
> 
> According to the chosen strategy explained in [PATCH 15/25], some
> defines become unnecessary. This patch removes them and adjusts
> probe.c to use ccid34_lib definitions directly
> 
> Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
> 
> Index: leandro.new/net/dccp/probe.c
> =================================
>  			 struct msghdr *msg, size_t size)
>  {
>  	const struct inet_sock *inet = inet_sk(sk);
> -	struct ccid3_hc_tx_sock *hctx = NULL;
> +	struct tfrc_hc_tx_sock *hctx = NULL;
>  
> -	if (ccid_get_current_id(dccp_sk(sk), false) = DCCPC_CCID3)
> -		hctx = ccid3_hc_tx_sk(sk);
> +        int current_ccid = ccid_get_current_id(dccp_sk(sk), false);
> +        switch (current_ccid) {
> +                case DCCPC_CCID3:
> +                case DCCPC_CCID4:
> +		        hctx = tfrc_hc_tx_sk(sk);
> +                        break;
> +        }
>  
>  	if (port = 0 || ntohs(inet->dport) = port ||
>  	    ntohs(inet->sport) = port) {

Another whitespace police hit. Also, I think declaration and assignment
of current_ccid should be grouped with other declarations.

---
 			 struct msghdr *msg, size_t size)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = NULL;
+	struct tfrc_hc_tx_sock *hctx = NULL;
+	int current_ccid = ccid_get_current_id(dccp_sk(sk), false);
 
-	if (ccid_get_current_id(dccp_sk(sk), false) = DCCPC_CCID3)
-		hctx = ccid3_hc_tx_sk(sk);
+	switch (current_ccid) {
+	case DCCPC_CCID3:
+	case DCCPC_CCID4:
+		hctx = tfrc_hc_tx_sk(sk);
+		break;
+	}
 
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
---

