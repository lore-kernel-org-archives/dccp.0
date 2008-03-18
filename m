From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 18 Mar 2008 11:30:35 +0000
Subject: Re: packet priorities
Message-Id: <20080318113035.GA4550@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > first of all - the idea and the basic design is _great_ and would like
| > to see the wheels in motion to get this into the test tree real soon.
| >
| Nice to hear that. It seems that in part I may have made my code too generic.
| 
Yes I think that is a bit the difficulty.

| >  * I think there should not be a sysctl for the policy, since each
| >    policy has specific dependencies, so that a user-changeable sysctl
| >    will just create confustion;
| In a sense you are right. In my code changing default policy to 1 makes no 
| sense without modifying the application. But we could imagine several 
| policies that have the same interface but slightly different behaviour...
And who am I to rule that out? Yet there are practical considerations.
There is a comment and a suggestion answering this point below.

| >  * some of the functions in the table might be rationalised away, if
| >    they are not doing much.
| >
| <irony>"rationalize away"? You simply want to kill them! I got quite used to 
| them over the last few days, so I'll fight hard for my functions ;-) </irony>
| 
You have to remember that not everyone will have the same enthusiasm for
a testing interface. People pulling the test tree will want something
which compiles, works out of the box first, and only then they might
think of experimental features.

I understand your position. But try to think with a longer-term
perspective, e.g. half a year or a year from now. What makes sense now
in prototypes and test programs will look differently then. And  it is really 
hard to get a function or a part of an established interface out once it has
become clear that there is no real use for it. 

The most recent example is the unused `more' argument in tx_packet_sent. No
one has ever used this parameter, yet it persisted for over 5 years. There are
similar examples - one is the ack_ratio parameter below, which you
pointed out.

It is much easier to add something to an existing interface when the need 
arises, but the other way round is much harder and confuses many.


| > With regard to filenames (policy.[ch]) it would be better to have a more
| > specific name (e.g. send_prios.[ch]), since this avoids confusion with
| > other parts. It would be great to have small description at the top of the
| > header (and maybe source) file.
| >
| send_prio would be a bit misleading since priorities are only in one of two 
| policies. But it could be something like queuing_policy{_simple,_prio}.[ch] 
| Would that be ok?
| 
Sounds good - maybe the identifiers get too long? There is this old constraint
(Documentation/CodingStyle) that lines should fit into 80 characters, so finding
a naming scheme which is both useful and allows to fit code into 80 lines is a
bit of an art.

| > ------------------------------------------
| > The data to pass on to the socket via cmsg
| > ------------------------------------------
| > 	struct dccp_policy_prio
| > 	{
| > 	       u8 priority;
| > 	};
| >
<snip>
| >
| I thought that using a structure would be a cleaner design. Especially when 
| one policy would use both time-to-live and priority. I didn't implement 
| time-to-live (or expiry time) just because it wasn't my priority for now.
| 
I agree, after considering the matter further. Indeed, choosing non-struct only will
limit the time-to-live to a single policy (e.g. "drop oldest packet first") and I
also think that a combined strategy of time-to-live plus priority is more flexible.
That is also the way Ian's code worked.
  

| > What do you think - is it necessary to have richer semantics? As far as I
| > can see, a sufficiently-large integer number already has quite a rich
| > semantics.
| >
| I see a structure as cleaner design which would allow us later to add more 
| fields without the need to change userspace source code.
| 
Agreed - good point. So I am assuming something like this

	struct dccp_policy_prio {
		int		priority;
		struct timeval	lifetime;
	};

And I think the above is already exaggerating: you asked earlier about the
maximum number of priority bands (~8?), so I think the above can be
reduced to "s8 priority" (-128 <= priority <= 127). Would that fit?

| > ----------------
| > The per-skb data
| > ----------------
| > @ -332,6 +337,7 @@ struct dccp_skb_cb {
| >         __u16 dccpd_opt_len;
| >         __u64 dccpd_seq;
| >         __u64 dccpd_ack_seq;
| > +       void* policy_data;
| >  };
| >
| > For the prio policy, the policy_data is the dccp_policy_prio struct, for
| > the simple policy it is the TX queue length. There is another comment
| > regarding the TX queue length below, I believe it is better to set the
| > queue length per-socket: there will only be one policy on the socket at one
| > time, and the queue length is a separate attribute.
| > My suggestion is to simply add a `dccp_policy_prio' field. If a number is
| > sufficient, this would be
| >
| > @ -332,6 +337,7 @@ struct dccp_skb_cb {
| >         __u16 dccpd_opt_len;
| >         __u64 dccpd_seq;
| >         __u64 dccpd_ack_seq;
| > +       int   dccp_policy_prio;
| >  };
| >
| > In this way, kmalloc/kfree/memcpy would not be required.
| >
| Did you mean tx_qlen instead of dccp_policy_prio?
Ah yes - the patch I took yesterday didn't have linux/dccp.h. Separate
answer below, this section is only about the struct dccp_skb_cb.

|Apart from that the questions are:
| 1. Can we imaging a policy for which tx_qlen will not make sense? Or a policy 
| for which it will be expressed in other units than packets? For example 
| bytes?
I can't think of an example at the moment, but this seems possible. The bytes-vs-packets
question comes up more in the CCIDs than in the sending interface. However, there is no
contradiction here: it is cleaner to keep the tx_qlen parameter separate from the queueing
policy. The first is an attribute of the queue, the latter is an algorithm of what to do
with the queue. 

But I think there is a point in here to keep the init() function pointer: if you can think
of a policy which depends on the queue length, this could be set via the init() function;
and the init function would be called after all the setsockopt options (thereby able to
override user defaults).

| 2. Can we imagine a policy which will have other per policy settings other 
| than tx_qlen?
Yes sure, but if the policy has private data should it not rather go into 
`struct queuing_policy'.

The above is the per-skb data; the question for this struct is "what is the
minimum amount of per-skb information that needs to be stored in dccp_skb_cb"?
And this is the same question as "what data needs to be passed via cmsg"?

So, if the struct dccp_policy_prio does not get too large, I am all for making
it a static part of the dccp_skb_cb.

The control buffer has 40 bytes, at the moment 15 bytes are already taken
for other DCCP data, so there is room for a modest prio struct.

| 3. Wouldn't this void* policy_data; be useful when trying to implement a more 
| advanced policy? I mean a policy may need a place to store data structures 
| used to manage data in queue. In two already written policies I don't use it, 
| but imagine I want to organize packets not in a list but in a heap-based 
| priority queue. Where would I put this structure without this kind of type 
| generic policy and socket specific field?
| 
With regard to internal data - as per (2). But I would like to answer a
question back: the per-skb data is only to establish an ordering amoung
the skbs, yes? So what else apart from a number to identify a ranking
within the list would you need? And secondly, you also have the
doubly-linked list underlying the skb queue at your disposal, which is
the second form of ordering. 

Or does your question point in another direction - using e.g. an array
instead of a doubly-linked list, to allow implementing heaps easier?

| > -------------
| > The interface
| > -------------
| > First of all - the idea is great and I really like the interface. I think
| > that some functions can be "rationalised" to make the interface leaner and
| > smaller (comments below), but that does not change the fact that the idea
| > of having a modular interface is excellent.
| >
| > struct queuing_policy
| > +{
| > +       unsigned char policy_id;
| > +       /* Interface Routines */
| > +       int (*pregister)(void);
| > +       int (*init)(struct sock *sk);
| > +       void (*push)(struct sock *sk, struct sk_buff *skb, void* control,
| > __kernel_size_t controllen); +       int (*full)(struct sock *sk);
| > +       struct sk_buff* (*top)(struct sock *sk);
| > +       void (*pop)(struct sock *sk, struct sk_buff *skb);
| > +       int (*setsockopt)(struct sock *sk, int optname, int optval);
| > +       int (*getsockopt)(struct sock *sk, int optname, int* optval);
| > +       int (*destroy)(struct sock *sk);
| > +};
| >
| > The push(), full(), top(), pop(), init(), and destroy() functions are
| > clear. The idea of using stack semantics is just great. It even allows one
| > to drop an old packet (via pop()) when the CCID has waited too long. I
| > really hope to see this soon in the tree.
| >
| In fact it's push() that discards data in policy_prio at least :-) pop() is 
| designed to discard only packets that were actually sent.
| 
Don't agree and it is difficult to guess what you had in mind since the
code has almost no documentation or comments. Some documentation would need to
be added. 
	
What you are stating is a side effect of policy_prio that only happens when 
length(queue) >= tx_qlen. Otherwise, prio_push() performs skb_queue_tail(),
as does simple_push(). And I was thinking of using pop() after the call
to ccid_hc_tx_send_packet() -- if the wait time is too long for the
packet, it can be discarded ("popped").

Actually, looking closer at _pop() I think it is not strictly necessary since 
it is an alias for skb_unlink(). Is there anything else that you think can
be done in _pop()?

| > I think that the get/setsockopt() functions should be part of the main DCCP
| > interface, not function pointers in a loadable unit, because:
| >  * this makes the interface simpler and avoids "case 256 ... 511";
| Simpler? Maybe. But at the same time less generic. Moreover I find nothing 
| wrong with "case 256 ... 511", similar code is used for getting info from 
| specific CCIDs so I followed the same pattern.
| 
But what does your `more generic' buy us? Generic is good only if you
have a large number of specific algorithms from which you want to
abstract. If there is no purpose that this serves, then it is just overhead.

| >  * simple_{get,set}sockopt() sets TX queue length. I think this should be
| > separate, since the length of the queue is a general attribute. This should
| > be a main-DCCP socket option,something like e.g. DCCP_SOCKOPT_TXQLEN. It is
| > good that you thought about it, I have heard at least one comment where
| > someone said that it would be good to set the TX queue length on a
| > per-socket basis. * prio_{get,set}sockopt() just return ENOPROTOOPT.
| >
| Answer to my earlier questions about tx_qlen in particular and policy specific 
| data in general will help us decide whether this is the place for 
| getsockopt/setsockopt. But don't look at those two functions as if their only 
| purpose was to get/set tx_qlen. They are meant to be more generic.
| 
Same point - I can't see any purpose served by the get/setsockopt
function pointers here. I had to sit down and think this one over. I
think you want to find a way of passing policy-specific data to the
policy struct, using either sysctls, specific get/setsockopt function
pointers.

Here is an alternative suggestion:
 * using a DCCP_SOCKOPT_QUEUING_POLICY as before (and use simple_prio 
   if no socket option is set) and
 * use a separate DCCP_SOCKOPT_QUEUING_POLICY_ARGS to pass arguments
   to the policy;
 * use default values if no ARGS are specified, or bail out with error
   if they are missing.


| > The other comment is the constructor: I think one of init() (preferable)
| > and pregister() is sufficient, but actually I am wondering whether
| > constructors/destructors are needed? Both destroy() functions are empty, so
| > is prio_init(), and simple_init() allocates an integer for the tx_qlen
| > (please see separate comment regarding TX queue length).
| >
| The tx_qlen is a completely different and possibly a very specific thing 
| mentioned several times already. As for empty simple_destroy: well there 
| probably should be a kfree(dp->dccps_policy_data); there.
| 
That was the thing I missed in the patch yesterday. Currently it is
using two fields

@@ -545,6 +549,8 @@ struct dccp_sock {
        __u8                            dccps_hc_tx_insert_options:1;
        __u8                            dccps_server_timewait:1;
        struct timer_list               dccps_xmit_timer;
+       struct queuing_policy   	*dccps_policy;
+       void                            *dccps_policy_data;
 };

I think this should be just one field for the policy, and the
policy_data can be an internal field of `struct queueing_policy'
(compare with struct ackvec or struct ccid).

I don't really like these `void' pointers: this works in user-space, but
we were having enough problems with unpredictable behaviour, so allowing
something to be of type `anything' makes debugging harder and opens the door
for bugs. If there is a way where you could achieve your goals without
void pointers, that would be great. But in some regards I have the
impression you are still brainstorming and defining the requirements of
the problems that this interface should be designed to solve, which is
why many things are left open. That is fine for discussing an interface 
as we are doing here, but it is not so good to put into a test tree that
is supposed to have a clean interface and work predictably.


| > The pregister() functions currently both register sysctls. This is not a
| > good idea, since sysctls are a global policy, but in your code they are
| > loaded/unloaded on a per-socket basis. This means you would have a clash
| > when using two different sockets with different policies: one would try to
| > load "dccp_prio_simple" sysctls and the other would try to load
| > "dccp_prio_other" sysctls - so they would "bite" each other. But when
| > taking the sysctls out of the pregister() functions, there is little left;
| > as a result register_queuing_policies() (and the call in dccp_sysctl_init)
| > could also be omitted.
| >
| I haven't checked that in practice but there should be no clash. The pregister 
| functions are executed in the same place where all other dccp sysctls are 
| registered. Which is I believe on dccp module load. And pregister functions 
| are not socket specific - note that they don't get struct sock *sk as 
| parameter (as opposed to init which is socket specific).
| 
Yes that was an oversight as I was skimming through the code. Indeed, they are 
decoupled from struct sock. But there still remains a problem: there is
now a bag of sysctls, where each sysctl depends on one particular
policy, and the socket only uses one policy at a time.

I have combined this with the earlier point regarding sysctls from the
beginning of the email.

| >  * there should not be per-policy sysctls - these are for global options
| >    and policies are changed per socket;
| I see two arguments here:
| 1. sysctls should be global. And they are a default for all new sockets using 
| that policy. Which means that they are in fact global.
Yes, but...

There is already an implied default policy, where I am assuming
simple_policy{} unless set via explicity socket option. So an
application which wants a specific policy, will need to set that policy
and will also know which data to pass, matching the selected policy. If
you have this information floating around in the sysctls, you will just
confuse the users.

My suggestion is as with the other functions that are not essentially
required: leave everything out which at the moment is not essential. If
we find, through half a year of testing and improving, that there is a
useful sysctl to set, it is a piece of cake to add it later.


| 2. sysctls should not affect only one 
| policy. /proc/sys/net/dccp/default/ack_ratio on the other hand seems to be 
| ccid2 specific.
| 
I am much more in favour of removing it than for keeping it, since it is exactly 
the same problem: ack_ratio in effect only works for CCID-2 and is entirely 
ignored by CCID-3 and CCID-4. It is the same thing - if an application wants to
change the Ack Ratio, it should do it on a per-connection basis, not globally.

Here is an instance of the point I am trying to make: a sysctl which only
makes sense half of the time and is useless the other part of the time,
an interface which confuses.

So I take this point up - it is valid, ack_ratio should be removed for
the same reason and should be replaced by a socket option. The interface
and basis for ACK_RATIO socket option and the feature negotiation code
is already there.

By the same token, the send_ackvec sysctl has already been removed in the test
tree since it is something that is done automatically.


| > Otherwise, if the constructors are not used (i.e. if there is no
| > policy-specific private data to allocate and de-allocate), I think it would
| > be better to not declare pregister(), init(), and destroy() at the moment.
| > One can always add more functions later.
| >
| I think that policy-specific private data (and so init and destroy functions) 
| could be useful for some policies. Note that standard sk_write_queue is not a 
| very sophisticated data structure and some policies might want to use 
| something more advanced to manage packets (to make it possibly faster).
| 
Agreed - by using null function pointers, they could just be declared
when needed.


| > When setting the TX queue length via socket options (as main-DCCP
| > setsockopt option, not as part of the policy), the tx_qlen sysctl is indeed
| > no longer necessary; I would be in favour of removing it, but other list
| > members may have a different view.
| >
| Seems tx_qlen is quite a specific case...
| 
There is one case which has not been mentioned so far: setting a tx_qlen
of 0 means using in effect an "infinite" TX queue. This is something to
consider for the queueing policy - whether it works with (in theory)
infinite queues, or better with a fixed (or policy-specific) queue size.

This could be done by the init() constructor function, thereby agreed it
is good to keep the constructor/destructor function pointers.
