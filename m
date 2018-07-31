From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 31 Jul 2018 17:51:09 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CACT4Y+Y6dhNgisDM9hdP-M-Rnk66DxZWcX7v39ESGJR8RY3asQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 31, 2018 at 7:41 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Tue, Jul 31, 2018 at 10:36 AM Christopher Lameter <cl@linux.com> wrote:
>
>>
>> If there is refcounting going on then why use SLAB_TYPESAFE_BY_RCU?
>
> To allow fast reuse of objects, without going through call_rcu() and
> reducing cache efficiency.
>
> I believe this is mentioned in Documentation/RCU/rculist_nulls.txt


Is it OK to overwrite ct->status? It seems that are some read and
writes to it right after atomic_inc_not_zero.
