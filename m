From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Jun 2008 12:39:04 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080630123904.GA10758@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > With the bitmask approach this constraint is expressed only once, when
| > the policy is defined in the source file.
| >
| In what I propose it would also be defined once. Instead of:
| 	[DCCPQ_POLICY_PRIO] = {
| 		.push	= qpolicy_simple_push,
| 		.full	= qpolicy_prio_full,
| 		.top	= qpolicy_prio_best_skb,
| 	},
| we would simply have:
| 	[DCCPQ_POLICY_PRIO] = {
| 		.push	= qpolicy_simple_push,
| 		.full	= qpolicy_prio_full,
| 		.top	= qpolicy_prio_best_skb,
| 		.params = DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT,
| 	},
| Doesn't seem complicated, does it?
| 
... and is also simpler than the bitmask approach. Very good idea: let's use this.


| > With the socket approach, the constraint needs to be expressed each time
| > the policy is used.
| >
| Yes. Two points:
| 1. The other option is /proc I guess... would that be better? I think not 
| (even though I had other optinion on this subject earlier).
Why put so much effort into this? All that is required is to refuse to
accept nonsensical parameters.

| 2. I think that it is actually good to enforce on application developers the 
| need to declare which parameters they want to use. This way they almost 
| cannot do it wrong.
| 
I don't agree: such a safety-net will only annoy good programmers who understand
what they are doing. And it will not help bad programmers much, since their problems
lie elsewhere. 

Further, the protection is not a strong one: nothing stops the user from first
declaring parameters X/Y and then supply something completely different.

| To make things clear: we both agree that the application should be able to get 
| information if the parameters it wants to use are supported by the kernel 
| it's running on, right?
| 
That is the central point. What we agree on is that that the policy should validate
the parameters that the user supplies via cmsg. We don't need the bitmask approach,
and with your suggested solution we have a mapping (.params field) between parameters
and policy IDs.

Which is sufficient to find out which parameters are acceptable for a policy.

| The place where we differ is that you would prefer to have:
| setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_POLICY_PRIO|(DCCP_SCM_PRIORITY<<8));
| 
| and I would like to have:
| setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_POLICY_PRIO);
| setsockopt(sockfd, DCCP_POLICY_PARAMS, DCCP_SCM_PRIORITY);
| 
| Is that right?
| -- 
Not quite. The first is just one way of relating policy IDs and parameters. First, as
above, I prefer your approach of using a .params field because it is simpler.    

With regard to the second point, I don't like the DCCP_POLICY_PARAMS socket option
since it does not prevent the user from using nonsensical parameters.

To summarise, what we have so far is:
 * qpolicy parameters are declared as disjoint bit values so that they can
   be or-ed together and tested with `&'/`=' operations;
 * the qpol_table gets a new (u32) field to keep the list of parameters
   that a policy accepts;
 * dccp_msghdr_parse() (net/dccp/proto.c) calls a qpolicy check routine to see
   if cmsg->cmsg_type is a parameter which is allowed by the  current qpolicy
 * if the parameter is not mentioned in the `.params' field of the qpol_table,
   dccp_msghdr_parse() returns -EINVAL.
