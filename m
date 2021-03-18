From: Eric Dumazet <edumazet@google.com>
Date: Thu, 18 Mar 2021 09:45:50 +0000
Subject: Re: [PATCH net] ipv6: weaken the v4mapped source check
Message-Id: <CANn89iLFMpSOwvhuT3_-yCZS1Ff7Vc5RPuO_DCNyYon3VSQW+w@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20210317165515.1914146-1-kuba@kernel.org>
In-Reply-To: <20210317165515.1914146-1-kuba@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Mar 17, 2021 at 5:55 PM Jakub Kicinski <kuba@kernel.org> wrote:
>
> This reverts commit 6af1799aaf3f1bc8defedddfa00df3192445bbf3.
>
> Commit 6af1799aaf3f ("ipv6: drop incoming packets having a v4mapped
> source address") introduced an input check against v4mapped addresses.
> Use of such addresses on the wire is indeed questionable and not
> allowed on public Internet. As the commit pointed out
>
>   https://tools.ietf.org/html/draft-itojun-v6ops-v4mapped-harmful-02
>
> lists potential issues.
>
> Unfortunately there are applications which use v4mapped addresses,
> and breaking them is a clear regression. For example v4mapped
> addresses (or any semi-valid addresses, really) may be used
> for uni-direction event streams or packet export.
>
> Since the issue which sparked the addition of the check was with
> TCP and request_socks in particular push the check down to TCPv6
> and DCCP. This restores the ability to receive UDPv6 packets with
> v4mapped address as the source.
>
> Keep using the IPSTATS_MIB_INHDRERRORS statistic to minimize the
> user-visible changes.
>
> Fixes: 6af1799aaf3f ("ipv6: drop incoming packets having a v4mapped source address")
> Reported-by: Sunyi Shao <sunyishao@fb.com>
> Signed-off-by: Jakub Kicinski <kuba@kernel.org>
> ---


Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks !
