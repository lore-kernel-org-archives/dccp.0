From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 30 Apr 2008 07:53:32 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080430075332.GA4277@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | > So we can reduce this to the other question "is 32 bit enough for
| > | > priority information".
| > |
| > | That is an important question. But I'm afraid the answer is no (even
| > | though I thought otherwise when writing previous mail). When we want to
| > | add packet expiry times we will need a field for timestamp. Which is
| > | quite big (64 bits?). But note that it is only needed for in-kernel
| > | implemetation. Userspace can write this information on as low as 16 bits.
| > | This leads me to conclusions stated below.
| >
| > I had the same thoughts - it is easy to end up with a wide range of
| > possible structs, numbers, etc. that are not related and require 20
| > different APIs.
| For now I can think of three possible solutions:
| a) one structure per policy (of course only if additional data is needed),
| b) one structure that could contain parameters from all possible policies 
| (that would mean that not all fields are used),
| c) allow qpolicy to use each cmsg header as different parameter. So that apart 
| from DCCP_SCM_PRIORITY we could also have DCCP_SCM_TIMEOUT_MS. And this seems 
| to be a very nice approach. It has several advantages:
|  - extensible,
|  - application does not need to pass parameter if it is ok with default value. 
| It could for example pass only DCCP_SCM_TIMEOUT_MS without DCCP_SCM_PRIORITY,
|  - it is easy to maintain compatibility.
| This series of parameters should be parsed by specific qpolicy that can make 
| use of them (read: prio). Other policies (read: simple) would not even 
| attempt to parse the list of parameters.
| 
I think (c) is best, here is what I'd support.

 1. Using different DCCP_SCM_xxx is definitively okay:
    the cmsg_type is `int', so there is more than enough room.

 2. I want to make the relationship between DCCP_SCM_xxx and the type passed
    as parameter explicit, i.e.

    - each DCCP_SCM_xxx has exactly one parameter type associated with it
      (e.g. DCCP_SCM_PRIORITY => uint32_t);

    - it is okay to associate the same parameter type with several
      different DCCP_SCM_xxx,but not ok to allow one DCCP_SCM_xxx to be
      associated with more than one parameter type or parameter length;

    - so that there is no confusion about the type of the parameters.

 3. Parsing and interpreting parameters to be kept separate, i.e. the qpolicy 
    routines read skb fields which have either been set from cmsg ancillary 
    data to sendmsg() or are otherwise initialised to default values. 


| > Also in (2) is the size question. The bottom line is if 2^32-1 different
| > numbers are sufficient to represent a range of policies, then we can
| > work with skb->priority for the moment.
| >
| > My understanding of the above is
| >  * the per-policy data is an opaque bitstring whose only requirement
| >    is that it fits within 32 bits;
| >  * how the bitstring is interpreted depends on the chosen policy;
| You mean data passed between userspace and kernelspace or in-kernel storage? 
| 1. For user to kernel data for me seems to be not expressive enough. Who knows 
| what these 32-bits are supposed to mean? Ok, we may document that but to me 
| it is almost like passing void*: you never know what's inside.
To me this means that you agree with (2) above. 
With (2) in place, the question does not arise.

| 2. For in-kernel storage 32-bits is simply not enough for priority+timeout.
Ok, but this is a separate question and it is about a yet non-existing policy.

So far there is a "priority" policy, for which I think we agree that 32
bits are enough.

Then there is a yet non-existing "timeout" policy, which has no associated
field yet. If we can assume that e.g. the skb->tstamp field can be used
to store timeouts, then there are separate fields associated with separate
policies.

And both associated parameters can be parsed differently, in particular
there is no requirement to restrict DCCP_SCM_TIMEOUT to use 32 bits - it
could even pass a struct timeval or struct timespec.

Thirdly, there is the aggregate policy "priority+timeout", which can
then use both skb->priority and skb->tstamp. 

I.e. to answer the question, I think it is best to implement "timeout" first,
solve the problems it brings up; when that is done, "priority+timeout" will
be easy to do - it could be constructed just out of the existing functions
defined for "priority" and "timeout".

In that manner, other policies can be modularly constructed - for instance
by combining "timeout" with a different form of the "priority" policy.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

