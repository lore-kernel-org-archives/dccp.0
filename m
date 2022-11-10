From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 10 Nov 2022 09:19:09 +0000
Subject: Re: [PATCH v1 net] dccp/tcp: Reset saddr on failure after inet6?_hash_connect().
Message-Id: <4c78a1d842899ca9a1a9ee9a79066db9489afe61.camel@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <20221103172419.20977-1-kuniyu@amazon.com>
In-Reply-To: <20221103172419.20977-1-kuniyu@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, 2022-11-03 at 10:24 -0700, Kuniyuki Iwashima wrote:
> When connect() is called on a socket bound to the wildcard address,
> we change the socket's saddr to a local address.  If the socket
> fails to connect() to the destination, we have to reset the saddr.
> 
> However, when an error occurs after inet_hash6?_connect() in
> (dccp|tcp)_v[46]_conect(), we forget to reset saddr and leave
> the socket bound to the address.
> 
> From the user's point of view, whether saddr is reset or not varies
> with errno.  Let's fix this inconsistent behaviour.
> 
> Note that with this patch, the repro [0] will trigger the WARN_ON()
> in inet_csk_get_port() again, but this patch is not buggy and rather
> fixes a bug papering over the bhash2's bug [1] for which we need
> another fix.
> 
> For the record, the repro causes -EADDRNOTAVAIL in inet_hash6_connect()
> by this sequence:
> 
>   s1 = socket()
>   s1.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
>   s1.bind(('127.0.0.1', 10000))
>   s1.sendto(b'hello', MSG_FASTOPEN, (('127.0.0.1', 10000)))
>   # or s1.connect(('127.0.0.1', 10000))
> 
>   s2 = socket()
>   s2.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
>   s2.bind(('0.0.0.0', 10000))
>   s2.connect(('127.0.0.1', 10000))  # -EADDRNOTAVAIL
> 
>   s2.listen(32)  # WARN_ON(inet_csk(sk)->icsk_bind2_hash != tb2);
> 
> [0]: https://syzkaller.appspot.com/bug?extid5d756bbd1f8b5c8f09
> [1]: https://lore.kernel.org/netdev/20221029001249.86337-1-kuniyu@amazon.com/
> 
> Fixes: 3df80d9320bc ("[DCCP]: Introduce DCCPv6")
> Fixes: 7c657876b63c ("[DCCP]: Initial implementation")
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>

As there is discussion on the correct approach here, I'm dropping this
patch from pw.

Eventually we can revive it later as needed.

Cheers,

Paolo
