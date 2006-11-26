From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 19:21:09 +0000
Subject: Re: [PATCH 10/10]: Simplify dccp_rcv_state_process
Message-Id: <39e6f6c70611261121k1b4f98bdpbd8fc7987672ff90@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611241620.18283@strip-the-willow>
In-Reply-To: <200611241620.18283@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/24/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Simplify dccp_rcv_state_process
>
> This patch does not change the algorithm, it just simplifies control flow a bit.
>
> The main changes are:
>  * cleanup after dccp_rcv_request_sent_state_process is now done within that function,
>    not in dccp_rcv_state_process
>  * as a result the control flow in dccp_rcv_request becomes a bit simpler

Gerrit, this one I have mixed feelings, as the simplification seems
OK, but the principle of staying as close to the TCP counterpart
(tcp_rcv_synsent_state_process) was the reason for me to leave parts
of the cleanup to the caller, because in TCP land we need to do
further processing with the skb before freeing it, so I'd prefer, for
now, not to deviate too much, even in simple things like this one.

- Arnaldo
