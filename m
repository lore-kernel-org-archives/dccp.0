From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 13 Mar 2007 02:27:52 +0000
Subject: Re: [ANNOUNCE]: Patch Preview
Message-Id: <39e6f6c70703121927k10e7a07as638e475b2e7b46fd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703121557.12709@strip-the-willow>
In-Reply-To: <200703121557.12709@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/12/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 3/12/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:

> > The new patches sound great but I find them hard to review all
> > combined. Arnaldo has asked for a git tree I see. Can that be
>
> No need for a git tree, I can apply it one by one here,what I said is
> that what gerryt has is equivalent to a git tree, i.e. a series of
> patches with comments and I don't want to lose that comments neither
> the separation.
>
> Will submit some more csets I have here for the skb layer header
> pointers series and merge this after a quick review (famous last
> words, lets see if its true today :-) ).

I started merging some, to speed up the process I'll accept some even
with reservations on some aspects of it, such as:

1a_simplify_seqno_arithmetic.diff:

- use of all upercase (ADD48, etc)
- DCCP_MAX_SEQNO should really be something like whats in
include/linux/kernel.h:

#define INT_MAX         ((int)(~0U>>1))
#define INT_MIN         (-INT_MAX - 1)
#define UINT_MAX        (~0U)
#define LONG_MAX        ((long)(~0UL>>1))
#define LONG_MIN        (-LONG_MAX - 1)
#define ULONG_MAX       (~0UL)
#define LLONG_MAX       ((long long)(~0ULL>>1))
#define LLONG_MIN       (-LLONG_MAX - 1)
#define ULLONG_MAX      (~0ULL)

But named UINT48_MAX or something in this direction, In fact I don't
see why these things are in kernel.h, they probably would be better of
in limits.h, like in userland.


1e_dccp_inc_seqno-no-pointer-variant.diff:

What is the point? INC48() is introduced but not used anywhere besides
in dccp_inc_seqno, where there is no changes with this patch, does the
other patches after this series use it?

The others in the 1e series looks OK apart from the issues mentioned
above, will try and continue tomorrow

Thanks a lot!

- Arnaldo
