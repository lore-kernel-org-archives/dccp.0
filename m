From: Eric Dumazet <edumazet@google.com>
Date: Tue, 31 Jul 2018 17:41:54 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CANn89iLLQP2vA+2J-zxL3Fa75zNw=yRmv3Jg6vcEc=fYeEZ2ow@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 31, 2018 at 10:36 AM Christopher Lameter <cl@linux.com> wrote:

>
> If there is refcounting going on then why use SLAB_TYPESAFE_BY_RCU?

To allow fast reuse of objects, without going through call_rcu() and
reducing cache efficiency.

I believe this is mentioned in Documentation/RCU/rculist_nulls.txt
