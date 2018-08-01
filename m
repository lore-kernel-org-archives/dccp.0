From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Aug 2018 10:23:17 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <c03fd1ca-0169-4492-7d6f-2df7a91bff5e@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On 08/01/2018 02:03 AM, Andrey Ryabinin wrote:

> I can't think of any advantage in not having the constructor. 
> 


I can't see any advantage adding another indirect call,
in RETPOLINE world.

