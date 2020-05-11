From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Mon, 11 May 2020 19:06:21 +0000
Subject: Re: [PATCH bpf-next v2 02/17] bpf: Introduce SK_LOOKUP program type with a dedicated attach point
Message-Id: <875zd2uw9e.fsf@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
References: <20200511185218.1422406-3-jakub@cloudflare.com>
In-Reply-To: <20200511185218.1422406-3-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, May 11, 2020 at 08:52 PM CEST, Jakub Sitnicki wrote:
> Add a new program type BPF_PROG_TYPE_SK_LOOKUP and a dedicated attach type
> called BPF_SK_LOOKUP. The new program kind is to be invoked by the
> transport layer when looking up a socket for a received packet.
>
> When called, SK_LOOKUP program can select a socket that will receive the
> packet. This serves as a mechanism to overcome the limits of what bind()
> API allows to express. Two use-cases driving this work are:
>
>  (1) steer packets destined to an IP range, fixed port to a socket
>
>      192.0.2.0/24, port 80 -> NGINX socket
>
>  (2) steer packets destined to an IP address, any port to a socket
>
>      198.51.100.1, any port -> L7 proxy socket
>
> In its run-time context, program receives information about the packet that
> triggered the socket lookup. Namely IP version, L4 protocol identifier, and
> address 4-tuple. Context can be further extended to include ingress
> interface identifier.
>
> To select a socket BPF program fetches it from a map holding socket
> references, like SOCKMAP or SOCKHASH, and calls bpf_sk_assign(ctx, sk, ...)
> helper to record the selection. Transport layer then uses the selected
> socket as a result of socket lookup.
>
> This patch only enables the user to attach an SK_LOOKUP program to a
> network namespace. Subsequent patches hook it up to run on local delivery
> path in ipv4 and ipv6 stacks.
>
> Suggested-by: Marek Majkowski <marek@cloudflare.com>
> Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
> Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
> ---
>
> Notes:
>     v2:
>     - Make bpf_sk_assign reject sockets that don't use RCU freeing.
>       Update bpf_sk_assign docs accordingly. (Martin)
>     - Change bpf_sk_assign proto to take PTR_TO_SOCKET as argument. (Martin)
>     - Fix broken build when CONFIG_INET is not selected. (Martin)
>     - Rename bpf_sk_lookup{} src_/dst_* fields remote_/local_*. (Martin)

I forgot to call out one more change in v2 to this patch:

      - Enforce BPF_SK_LOOKUP attach point on load & attach. (Martin)

[...]
