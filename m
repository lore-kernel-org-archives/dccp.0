From: Eric Dumazet <edumazet@google.com>
Date: Mon, 23 Mar 2020 18:45:48 +0000
Subject: Re: [PATCH net-next 1/2] tcp/dccp: Move initialisation of refcounted into if block.
Message-Id: <CANn89iJzxqF8j6uUO9BqmMY0tVh+intVj-v-tygXc_8r6-wjkg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20200323181814.87661-2-kuniyu@amazon.co.jp>
In-Reply-To: <20200323181814.87661-2-kuniyu@amazon.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Mar 23, 2020 at 11:18 AM Kuniyuki Iwashima <kuniyu@amazon.co.jp> wrote:
>
> The refcounted is initialised at most three times.
>
>   - __inet_lookup_skb() sets it true.
>   - skb_steal_sock() is false and __inet_lookup() sets it true.
>   - __inet_lookup_established() is false and __inet_lookup() sets it false.
>
> We do not need to initialise refcounted again and again, so we should do
> it just before return.
>
> Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
> ---

Well, I do not believe this patch (and the following one) makes things
more readable.

I doubt setting a boolean in a register or a stack variable has any cost,
I prefer letting the compiler optimize this.

The ehash lookup cost is at least 2 or 3 cache lines, this is the
major contribution.
