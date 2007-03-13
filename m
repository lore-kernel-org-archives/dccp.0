From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 Mar 2007 07:31:26 +0000
Subject: Re: [ANNOUNCE]: Patch Preview
Message-Id: <200703130731.26644@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703121557.12709@strip-the-willow>
In-Reply-To: <200703121557.12709@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  I started merging some, to speed up the process I'll accept some even
|  with reservations on some aspects of it, such as:
Please do let me know those reservations. I'd rather revise a patch several
times than submitting something which is only half as good as could be.

  
|  1a_simplify_seqno_arithmetic.diff:
|  
|  - use of all upercase (ADD48, etc)
|  - DCCP_MAX_SEQNO should really be something like whats in
|  include/linux/kernel.h:
|  
|  #define INT_MAX         ((int)(~0U>>1))
|  #define INT_MIN         (-INT_MAX - 1)
|  #define UINT_MAX        (~0U)
|  #define LONG_MAX        ((long)(~0UL>>1))
|  #define LONG_MIN        (-LONG_MAX - 1)
|  #define ULONG_MAX       (~0UL)
|  #define LLONG_MAX       ((long long)(~0ULL>>1))
|  #define LLONG_MIN       (-LLONG_MAX - 1)
|  #define ULLONG_MAX      (~0ULL)
|  
|  But named UINT48_MAX or something in this direction, In fact I don't
|  see why these things are in kernel.h, they probably would be better of
|  in limits.h, like in userland.
I fully agree, will re-submit a v2 later on. If you don't mind, I'd prefer
to keep the long (LL) hex constants in the definition of INT48_MIN/UINT48_MAX.
  
  
|  1e_dccp_inc_seqno-no-pointer-variant.diff:
|  
|  What is the point? INC48() is introduced but not used anywhere besides
|  in dccp_inc_seqno, where there is no changes with this patch, does the
|  other patches after this series use it?
The purpose of the INC48() macro is to increment bitfield u64 counters
(those which were declared as u64 ccidvariable:48, ... ). The macro is
not currently used by the code, it had initially been used for a piece
of code Ian wrote. Since no other patches are currently depend on it, 
and since there are already the ADD48/SUB48 macros, I have dropped this
patch - hope you are happy with this. 

(Btw, follows48 (of patch 1d) is also no longer used and could be dropped, 
 but this can only be done when all other patches are applied).

Many thanks for looking into this and for feedback 
Gerrit
