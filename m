From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 01 Aug 2018 10:34:54 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CACT4Y+bLbDunoz+0qB=atbQXJ9Gu3N6+UXPwNnqMbq5RyZu1mQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 12:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On 08/01/2018 02:03 AM, Andrey Ryabinin wrote:
>
>> I can't think of any advantage in not having the constructor.
>
> I can't see any advantage adding another indirect call,
> in RETPOLINE world.

Can you please elaborate what's the problem here?
If slab ctor call have RETPOLINE, then using ctors more does not
introduce any security problems and they are not _that_ slow.
If slab ctors are not protected, then we have problem that needs to be
fixed already.
What am I missing?
