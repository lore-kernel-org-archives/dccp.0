From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Aug 2018 16:25:55 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <bf435a04-b689-ec5a-f5df-f47807b43316@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On 08/01/2018 09:22 AM, Christopher Lameter wrote:
> On Wed, 1 Aug 2018, Eric Dumazet wrote:
> 
>> The idea of having a ctor() would only be a win if all the fields that
>> can be initialized in the ctor are contiguous and fill an integral
>> number of cache lines.
> 
> Ok. Its reducing code size and makes the object status more consistent.
> Isn't that enough?
> 

Prove it ;)

I yet have to seen actual numbers.
