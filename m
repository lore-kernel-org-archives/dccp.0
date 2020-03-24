From: David Miller <davem@davemloft.net>
Date: Tue, 24 Mar 2020 23:23:20 +0000
Subject: Re: [PATCH v2 net-next] tcp/dccp: Move initialisation of refcounted into if block.
Message-Id: <20200324.162320.60114994463504898.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20200324113331.29031-1-kuniyu@amazon.co.jp>
In-Reply-To: <20200324113331.29031-1-kuniyu@amazon.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
Date: Tue, 24 Mar 2020 20:33:31 +0900

> The refcounted seems to be initialised at most three times, but the
> complier can optimize that and the refcounted is initialised only at once.
> 
>   - __inet_lookup_skb() sets it true.
>   - skb_steal_sock() is false and __inet_lookup() sets it true.
>   - __inet_lookup_established() is false and __inet_lookup() sets it false.
> 
> The code is bit confusing, so this patch makes it more readable so that no
> one doubt about the complier optimization.
> 
> Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.co.jp>

I don't think this improves the code readability nor code generation, it's
just noise changes and will make backporting more difficult.

I'm not applying this sorry.

In the future, I am going to apply a large threshold as to whether
changes like this are reasonable and appropriate.  Please keep that
in mind for your submissions.

Thank you.
