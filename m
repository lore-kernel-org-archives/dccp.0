From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 01 Aug 2018 11:35:09 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CACT4Y+b6aCHMTQD21fSf2AMZoH5g8p-FuCVHviMLF00uFV+zGg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 1:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On 08/01/2018 03:34 AM, Dmitry Vyukov wrote:
>> On Wed, Aug 1, 2018 at 12:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On 08/01/2018 02:03 AM, Andrey Ryabinin wrote:
>>>
>>>> I can't think of any advantage in not having the constructor.
>>>
>>> I can't see any advantage adding another indirect call,
>>> in RETPOLINE world.
>>
>> Can you please elaborate what's the problem here?
>> If slab ctor call have RETPOLINE, then using ctors more does not
>> introduce any security problems and they are not _that_ slow.
>
> They _are_ slow, when we have dozens of them in a code path.
>
> I object "having to add" yet another indirect call, if this can be avoided [*]
>
> If some people want to use ctor, fine, but do not request this.
>
> [*] This can be tricky, but worth the pain.

But we are trading 1 indirect call for comparable overhead removed
from much more common path. The path that does ctors is also calling
into page alloc, which is much more expensive.
So ctor should be a net win on performance front, no?
