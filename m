From: Eric Dumazet <edumazet@google.com>
Date: Tue, 22 Nov 2022 17:54:11 +0000
Subject: Re: [PATCH v4 net 0/4] dccp/tcp: Fix bhash2 issues related to WARN_ON() in inet_csk_get_port().
Message-Id: <CANn89iLTh6OPb0LLcAnfzZPt8jDtfyUo5xDA4c0gL4534xmiOg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20221119014914.31792-1-kuniyu@amazon.com>
In-Reply-To: <20221119014914.31792-1-kuniyu@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Nov 18, 2022 at 5:49 PM Kuniyuki Iwashima <kuniyu@amazon.com> wrote:
>
> syzkaller was hitting a WARN_ON() in inet_csk_get_port() in the 4th patch,
> which was because we forgot to fix up bhash2 bucket when connect() for a
> socket bound to a wildcard address fails in __inet_stream_connect().
>
> There was a similar report [0], but its repro does not fire the WARN_ON() due
> to inconsistent error handling.
>
> When connect() for a socket bound to a wildcard address fails, saddr may or
> may not be reset depending on where the failure happens.  When we fail in
> __inet_stream_connect(), sk->sk_prot->disconnect() resets saddr.  OTOH, in
> (dccp|tcp)_v[46]_connect(), if we fail after inet_hash6?_connect(), we
> forget to reset saddr.
>
> We fix this inconsistent error handling in the 1st patch, and then we'll
> fix the bhash2 WARN_ON() issue.
>
> Note that there is still an issue in that we reset saddr without checking
> if there are conflicting sockets in bhash and bhash2, but this should be
> another series.
>
> See [1][2] for the previous discussion.
>
> [0]: https://lore.kernel.org/netdev/0000000000003f33bc05dfaf44fe@google.com/
> [1]: https://lore.kernel.org/netdev/20221029001249.86337-1-kuniyu@amazon.com/
> [2]: https://lore.kernel.org/netdev/20221103172419.20977-1-kuniyu@amazon.com/
> [3]: https://lore.kernel.org/netdev/20221118081906.053d5231@kernel.org/T/#m00aafedb29ff0b55d5e67aef0252ef1baaf4b6ee
>
>
> Changes:
>   v4:
>     * Patch 3
>       * Narrow down the bhash lock section (Joanne Koong)
>
>   v3: https://lore.kernel.org/netdev/20221118205839.14312-1-kuniyu@amazon.com/
>     * Patch 3
>       * Update saddr under the bhash's lock
>       * Correct Fixes tag
>       * Change #ifdef in inet_update_saddr() along the recent
>         discussion [3]
>
>   v2: https://lore.kernel.org/netdev/20221116222805.64734-1-kuniyu@amazon.com/
>     * Add patch 2-4
>
>   v1: [2]
>
>
> Kuniyuki Iwashima (4):
>   dccp/tcp: Reset saddr on failure after inet6?_hash_connect().
>   dccp/tcp: Remove NULL check for prev_saddr in
>     inet_bhash2_update_saddr().
>   dccp/tcp: Update saddr under bhash's lock.
>   dccp/tcp: Fixup bhash2 bucket when connect() fails.

SGTM, thanks !

Reviewed-by: Eric Dumazet <edumazet@google.com>
