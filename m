From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 13 Dec 2005 03:17:17 +0000
Subject: Re: [PATCH 2/2][IP_SOCKGLUE]: Remove most of the tcp specific calls
Message-Id: <39e6f6c70512121917y17202149x41ac4e9d8826c354@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70512121603k4fa2a924k3ee75c1fb6a0fa4e@mail.gmail.com>
In-Reply-To: <39e6f6c70512121603k4fa2a924k3ee75c1fb6a0fa4e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/12/05, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> Hi David,
>
>   Please consider pulling from:
>
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Oops, there was a bug introduced by this patch at this hunk:

@@ -870,7 +872,7 @@ static struct sock * tcp_v6_syn_recv_soc
 		   worked with IPv6 icsk.icsk_af_ops.
 		   Sync it now.
 		 */
-		tcp_sync_mss(newsk, newtp->pmtu_cookie);
+		tcp_sync_mss(newsk, inet_csk(sk)->icsk_pmtu_cookie);

 		return newsk;
 	}

It should have been inet_csk(newsk)-> ...

Fixed in the (reworked) submitted tree.

Best Regards,

- Arnaldo
