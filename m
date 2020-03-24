From: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
Date: Tue, 24 Mar 2020 11:06:05 +0000
Subject: Re: [PATCH net-next 2/2] tcp/dccp: Remove unnecessary initialization
Message-Id: <20200324110605.10050-1-kuniyu@amazon.co.jp>
List-Id: <dccp.vger.kernel.org>
References: <20200323181814.87661-3-kuniyu@amazon.co.jp>
In-Reply-To: <20200323181814.87661-3-kuniyu@amazon.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From:   Eric Dumazet <edumazet@google.com>
Date:   Mon, 23 Mar 2020 11:47:17 -0700
> On Mon, Mar 23, 2020 at 11:22 AM Kuniyuki Iwashima <kuniyu@amazon.co.jp> wrote:
> >
> > When we get a TCP_NEW_SYN_RECV/DCCP_NEW_SYN_RECV socket by
> > __inet_lookup_skb(), refcounted is already set true, so it is not
> > necessary to do it again.
> 
> This changelog is absolutely not accurate.
> 
> sk is a listener here.
> (because sk was set to req->rsk_listener;)
> 
> Please do not add confusion by mixing different things.
> 
> I prefer not relying on the old value of 'refcounted', since we
> switched sk value.
> 
> Note that we call reqsk_put(req); regardless of 'refcounted'

Certainly, the refcounted has diffrent meaning in the context, sorry. 


> I would rather not change this code and make future backports more complicated.
> 
> Thanks.

I did not think about backports, thank you!
