From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 20 Mar 2008 15:52:59 +0000
Subject: Re: packet priorities
Message-Id: <20080320155259.GA30049@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Tomasz, -

| > | > With regard to filenames (policy.[ch]) it would be better to have a
| > | > more specific name (e.g. send_prios.[ch]), since this avoids confusion
| > | > with other parts. It would be great to have small description at the
| > | > top of the header (and maybe source) file.
| > |
| > | send_prio would be a bit misleading since priorities are only in one of
| > | two policies. But it could be something like
| > | queuing_policy{_simple,_prio}.[ch] Would that be ok?
Sounds very good since it is almost immediately clear what the files
contain and do.

In general, it is Arnaldo who decides these things - I was hoping he
would chip in into the discussion. But if the format is already in a
clear state, it will make his work easier.

| >
| > Sounds good - maybe the identifiers get too long? There is this old
| > constraint (Documentation/CodingStyle) that lines should fit into 80
| > characters, so finding a naming scheme which is both useful and allows to
| > fit code into 80 lines is a bit of an art.
| >
| Would qpolicy be understandable? And maybe qp_ or qpol_ where something extra 
| short is necessary.
| 
The naming convention, as far as I know it, for structs and functions is
 * dccp_xxx        for general DCCP parts
 * ccid_xxx        for code specific to CCIDs
 * dccp_ackvec_xxx for code specific to Ack Vectors
 * dccp_feat_xxx   for code specific to Feature Negotiation
There was an earlier discussion that `dccp_ackvec_xxx' is maybe a bit
long, so I am guessing that dccp_qpol_xxx dccp_qpolicy_xxx will work
fine - again a question for Arnaldo really. 


| > Agreed - good point. So I am assuming something like this
| >
| > 	struct dccp_policy_prio {
| > 		int		priority;
| > 		struct timeval	lifetime;
| > 	};
| >
| > And I think the above is already exaggerating: you asked earlier about the
| > maximum number of priority bands (~8?), so I think the above can be
| > reduced to "s8 priority" (-128 <= priority <= 127). Would that fit?
| >
| Yes, I meant to develop it in that direction. But that is merely 
| implementation of one of the policies.
| 


| > |Apart from that the questions are:
| > | 1. Can we imaging a policy for which tx_qlen will not make sense? Or a
| > | policy for which it will be expressed in other units than packets? For
| > | example bytes?
| >
| > I can't think of an example at the moment, but this seems possible. The
| > bytes-vs-packets question comes up more in the CCIDs than in the sending
| > interface. However, there is no contradiction here: it is cleaner to keep
| > the tx_qlen parameter separate from the queueing policy. The first is an
| > attribute of the queue, the latter is an algorithm of what to do with the
| > queue.
| >
| In object oriented languages attributes (tx_qlen but potentially others) and 
| operations constitute a class. So they are not at all separate concepts.
| 
There is a lot of object-oriented-like design underlying the
implementation of DCCP, and it is thanks to Arnaldo's specialisation
hierarchy of sockets (dccp_sock specialises inet_connection_sock, which 
specialises inet_sock, which inherits from struct sock). I agree with
your argument (operations and data should go together), but in a way
they do; why tx_qlen is special is continued at end of email.



| > But I think there is a point in here to keep the init() function pointer:
| > if you can think of a policy which depends on the queue length, this could
| > be set via the init() function; and the init function would be called after
| > all the setsockopt options (thereby able to override user defaults).
| >
| Choosing way the packets are queued by a policy based on requested queue 
| length might be an interesting feature I haven't thought about. But note that 
| setsockopts for changing policy and changing queue length can be called in 
| any order. If we first change the policy (hence call init()) and then change 
| queue length (which, as you propose, would not call any policy specific 
| function) then we end up with somewhat inconsistent state.
| 
Good point, this needs order. I'd like to ask one question to clarify:
 (1) Changing the policy during the connection: is there any real
     benefit in doing this? If you want to allow changing the policy 
     on-the-fly, while the connection is going on, problems arise:
     - there may still be data in the queue which uses the previous
       policy. Currently the way the per-skb data is interpreted is
       implicit (but clear) from which policy is currently chosen. If
       there are transition periods between changing policies, it gets
       messy.
     - It gets more complicated if the policy use dynamic data which is
       allocated and de-allocated.
     - Synchronisation with e.g. tx_qlen becomes a problem (next point).
     If at all possible, using a single policy per connection will keep
     the implementation clear and simple, otherwise it is complex (this
     is from own lessons learned with the feature negotiation code).

 (2) Synchronisation between setting tx_qlen and policy: when using a
     single policy then the synchronisation can be achieved by allowing
     the setsocktopt for policy/tx_qlen only on unconnected socket; and
     by calling init() when the socket moves into the connected state.
     In this way the policy is able to modify tx_qlen (and other
     changeable data) in such a way that it begins operation in a
     consistent state. I can't think of a way of synchronising when the
     policy can change on the fly, so this question is the same as (1).


| > The above is the per-skb data; the question for this struct is "what is the
| > minimum amount of per-skb information that needs to be stored in
| > dccp_skb_cb"? And this is the same question as "what data needs to be
| > passed via cmsg"?
| >
| Minimum? Nothing. As in policy_simple.
| 
Oops, misunderstood question - what I meant was minimum in terms of "what is the
minimum data unit (signed/unsigned integer, struct)" that is passed to cmsg?
We have already full agreement that it is a struct, if the same type of
struct could be used for most (all) policies, it would be very elegant
and keep the API simple. 

Otherwise, you could keep it extensible by adding new fields at the end
of the struct (which is often done to keep implementations compatible).


| > So, if the struct dccp_policy_prio does not get too large, I am all for
| > making it a static part of the dccp_skb_cb.
| >
| > The control buffer has 40 bytes, at the moment 15 bytes are already taken
| > for other DCCP data, so there is room for a modest prio struct.
| >
| I'm not very keen on making one master struct and claiming that nobody will 
| ever need anything more advanced. But we could use the same mechanism by 
| which we got our 48 bytes from struct sk_buff. We could allocate a fixed 
| buffer by means of "char policy_data[16];" and each policy would cast it to 
| policy specific struct. Exactly the same way we cast sk_buff::cb to 
| dccp_skb_cb. Would that be ok?
| 
I agree with the concept - is it possible to achieve the same by using a
struct which works for all current policies and which can be extended 
to future policies by adding new fields at the end? This takes some
burden off the current implementation.


| > Actually, looking closer at _pop() I think it is not strictly necessary
| > since it is an alias for skb_unlink(). Is there anything else that you
| > think can be done in _pop()?
| >
| Imagine the packets are organized in a heap. Deleting a node from a heap is 
| possibly something more than skb_unlink().
| 
And it is also clearer for the interface. Yes, pop() is a good idea -- I was
just interested what else could be done in pop(). 


| >
| > Same point - I can't see any purpose served by the get/setsockopt
| > function pointers here. I had to sit down and think this one over. I
| > think you want to find a way of passing policy-specific data to the
| > policy struct, using either sysctls, specific get/setsockopt function
| > pointers.
| >
| Yes, I wanted to use both. sysctls for global default values and 
| set/setsockopt for individual per socket settings. And while sysctls are not 
| a must have I think that get/setsockopt would be a nice thing. One could for 
| example provide userspace applications with information on how the policy is 
| operating (average queue length, number of dropped/sent packets per band, 
| number of timed out packets, etc.).
| 
Agree now with the set/getsockopts, sorry it took me a bit longer to
understand. But am still uneasy with the sysctls, since they will
apply only to some specific policy.


| > Here is an alternative suggestion:
| >  * use a separate DCCP_SOCKOPT_QUEUING_POLICY_ARGS to pass arguments
| >    to the policy;
| But that would still require some policy specific function to process data 
| passed to this DCCP_SOCKOPT_QUEUING_POLICY_ARGS sockopt, wouldn't it?
| 
... which shows that the idea of a separate sockopt option was not such
a good one. So agree, if data needs to be passed into the policy, then
a policy-setsockopt function is a clean way.

With regard to the naming convention - in the current kernel there is
a division only for the TX/RX CCIDs (128...191 and 192...255) and this
comes from RFC 4340, 10.3. When introducing subsystem-specific socket
options, it would make sense to define these as symbolic names, e.g.

#define DCCP_QPOLICY_OPT_MIN	256 /* start of policy-specific options */
#define DCCP_QPOLICY_OPT_MAX	511 /* end of policy-specific options */

(and then `case DCCP_QPOLICY_OPT_MIN ... DCCP_QPOLICY_OPT_MAX).



| > I don't really like these `void' pointers: this works in user-space, but
| > we were having enough problems with unpredictable behaviour, so allowing
| > something to be of type `anything' makes debugging harder and opens the
| > door for bugs. If there is a way where you could achieve your goals without
| > void pointers, that would be great. But in some regards I have the
| I don't like them either. In C++ this would be a pointer to abstract class 
| (interface) or base class. But in C we have to fall back to "void* 
| priv_data;" or "char priv_data[0];" (as in struct ccid). For now I don't see 
| a better way...
| 
There are alternatives. One way is to define a maximum-sized data type, i.e.
if only numbers (for priority ranking) are needed, to use a large (signed) number.

If there are specialisation hierarchies, the base struct can be contained as first
element of the struct, and instantiating the subclass can be done by
typecasting. Another one is below.



| My point about tx_qlen is that it affects how a policy works and should 
| therefore be policy specific setting managed by the policy. For me it 
| logically belongs to a policy. The main weakness of this design is that 
| tx_qlen exists in all policies I can think of...
I agree with both points and have looked back at the code: what I said
was not exactly accurate and I think it contributed to some confusion
regarding sysctls and socket options: currently the tx_qlen is a single
sysctl for all connections/sockets, there is no per-socket information
for tx_qlen (apart from the `qlen' field of the sk_write_queue).

So yes, I think you are right - it needs to be part of the private data
of the policy, even if it re-appears in all known policies.

Now I also know what you meant by the `void' pointers, and there is a
known way to resolve this in an IMO elegant way. Again the role model
is to be found in net/dccp/ccid.{c,h}:

	struct ccid {
		struct ccid_operations *ccid_ops;
		char                   ccid_priv[0];
	};

	static inline void *ccid_priv(const struct ccid *ccid)
	{
		return (void *)ccid->ccid_priv;
	}

In this way, private data of struct queuing_policy can be anything
instance-specific, and yet be accessed in a uniform manner.

With regard to the tx_qlen - as it re-appears in all known policies,
it would be a candidate (permanent) field of the struct queueing_policy.     


Gerrit
