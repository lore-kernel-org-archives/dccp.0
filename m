From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 01 Jul 2008 12:38:45 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <486A2555.9050901@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker pisze:
> | > With the bitmask approach this constraint is expressed only once, when
> | > the policy is defined in the source file.
> | >
> | In what I propose it would also be defined once. Instead of:
> | 	[DCCPQ_POLICY_PRIO] = {
> | 		.push	= qpolicy_simple_push,
> | 		.full	= qpolicy_prio_full,
> | 		.top	= qpolicy_prio_best_skb,
> | 	},
> | we would simply have:
> | 	[DCCPQ_POLICY_PRIO] = {
> | 		.push	= qpolicy_simple_push,
> | 		.full	= qpolicy_prio_full,
> | 		.top	= qpolicy_prio_best_skb,
> | 		.params = DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT,
> | 	},
> | Doesn't seem complicated, does it?
> | 
> ... and is also simpler than the bitmask approach. Very good idea: let's use this.
> 
Ok, so now we know how to store information about parameters in kernel
structures. What remains to be discussed is how to pass that information
to userspace.

> | > With the socket approach, the constraint needs to be expressed each time
> | > the policy is used.
> | >
> | Yes. Two points:
> | 1. The other option is /proc I guess... would that be better? I think not 
> | (even though I had other optinion on this subject earlier).
> Why put so much effort into this?
Now I think that /proc is overly complicated approach.

> All that is required is to refuse to
> accept nonsensical parameters.
> 
You can refuse to accept them on sendmsg(). And IMO the application 
should be able to determine which parameters are correct earlier.

> | 2. I think that it is actually good to enforce on application developers the 
> | need to declare which parameters they want to use. This way they almost 
> | cannot do it wrong.
> | 
> I don't agree: such a safety-net will only annoy good programmers who understand
> what they are doing. And it will not help bad programmers much, since their problems
> lie elsewhere. 
> 
The history of software development shows that with newer programming 
languages you can do yourself less and less harm. Think of machine code 
-> assembler -> C -> C++ -> Java/C#. Ok, the last two languages assume 
the programmer is dumb but their success shows that people want 
fool-proof development environments (even if it restricts capabilities). 
In fact they want everything to be fool-proof (from toothbrush to car).

> Further, the protection is not a strong one: nothing stops the user from first
> declaring parameters X/Y and then supply something completely different.
> 
We could make it strong that is enforce that when a parameter was not 
declared it cannot be used.

> | To make things clear: we both agree that the application should be able to get 
> | information if the parameters it wants to use are supported by the kernel 
> | it's running on, right?
> | 
> That is the central point. What we agree on is that that the policy should validate
> the parameters that the user supplies via cmsg. 
Yes. But it's only part of the problem. We should also allow 
applications to detect which parameters are ok before calling sendmsg().

> We don't need the bitmask approach,
> and with your suggested solution we have a mapping (.params field) between parameters
> and policy IDs.
> 
> Which is sufficient to find out which parameters are acceptable for a policy.
> 
The .param field idea only shows how we store that information in 
kernel. It doesn't show how the user can retrieve that information.

> | The place where we differ is that you would prefer to have:
> | setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_POLICY_PRIO|(DCCP_SCM_PRIORITY<<8));
> | 
> | and I would like to have:
> | setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_POLICY_PRIO);
> | setsockopt(sockfd, DCCP_POLICY_PARAMS, DCCP_SCM_PRIORITY);
> | 
> | Is that right?
> | -- 
> Not quite. 
I knew we must have been talking different languages ;-)

> The first is just one way of relating policy IDs and parameters. First, as
> above, I prefer your approach of using a .params field because it is simpler.    
> 
Ok.

> To summarise, what we have so far is:
>  * qpolicy parameters are declared as disjoint bit values so that they can
>    be or-ed together and tested with `&'/`=' operations;
>  * the qpol_table gets a new (u32) field to keep the list of parameters
>    that a policy accepts;
>  * dccp_msghdr_parse() (net/dccp/proto.c) calls a qpolicy check routine to see
>    if cmsg->cmsg_type is a parameter which is allowed by the  current qpolicy
>  * if the parameter is not mentioned in the `.params' field of the qpol_table,
>    dccp_msghdr_parse() returns -EINVAL.
Yes, that's better than what we currently have (and I'll try to 
implement a patch for this).

But this still means that the application that wants to use 
DCCP_SCM_TIMEOUT can get information that it's not supported on calling 
sendmsg(). Which is IMO too late.
-- 
Regards,
Tomasz Grobelny
