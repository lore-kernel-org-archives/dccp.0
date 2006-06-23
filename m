From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 23 Jun 2006 07:45:49 +0000
Subject: Re: Locking validator output on DCCP
Message-Id: <20060623074549.GA30155@elte.hu>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
In-Reply-To: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


* Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:

> OK. This is in net/ipv4/tcp_ipv4.c tcp_v4_rcv with the 
> bh_lock_sock_nested which I presume is clashing with the nested of 
> skb_clone....

yeah, that's exactly what happens.

> Can we not do two levels nested?

we can - but it needs to be thought through (and needs to be tested). 
But an initial glance seems to suggest that two levels, one used for 
clone and another one used for tcp_v4_rcv nesting ought to do the trick.

> Is there extra documentation for the locking validation suite so that 
> I can stop asking stupid questions? If not I'll just read more of the 
> source code.

i'd suggest to start with: Documentation/lockdep-design.txt, then with 
include/linux/lockdep.h and also look at some of the existing patches 
that introduce multiple nesting levels, such as:

    http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17/2.6.17-mm1/broken-out/lock-validator-special-locking-dcache.patch

the best method is to find the proper central header for the level enum, 
and then make use of it. The enum should have a descriptive name, and 
the enum values too.

If one particular lock has multiple levels then SINGLE_DEPTH_NESTING 
should not be used. (to keep the levels architecture clean) I.e. 
possibly the best idea would be to extend bh_lock_sock_nested() with a 
'subtype' parameter, and to pass that into spin_lock_nested().

Or even better: define bh_lock_sock_nested() as an inline function with 
the right enum parameter, which will make sure only the right type of 
enum will be used. [if it's possible to do it as an inline there - it's 
a macro right now and i'm not sure all the types necessary for the 
inline are declared up to that point in the sock.h include file]

	Ingo
