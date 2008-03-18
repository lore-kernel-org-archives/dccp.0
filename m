From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 18 Mar 2008 23:24:43 +0000
Subject: Re: packet priorities
Message-Id: <200803190024.44136.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 18 of March 2008, Gerrit Renker napisa=B3:
> I understand your position. But try to think with a longer-term
> perspective, e.g. half a year or a year from now. What makes sense now
> in prototypes and test programs will look differently then. And  it is
> really hard to get a function or a part of an established interface out
> once it has become clear that there is no real use for it.
>
> It is much easier to add something to an existing interface when the need
> arises, but the other way round is much harder and confuses many.
>
Ok.

> | > With regard to filenames (policy.[ch]) it would be better to have a
> | > more specific name (e.g. send_prios.[ch]), since this avoids confusion
> | > with other parts. It would be great to have small description at the
> | > top of the header (and maybe source) file.
> |
> | send_prio would be a bit misleading since priorities are only in one of
> | two policies. But it could be something like
> | queuing_policy{_simple,_prio}.[ch] Would that be ok?
>
> Sounds good - maybe the identifiers get too long? There is this old
> constraint (Documentation/CodingStyle) that lines should fit into 80
> characters, so finding a naming scheme which is both useful and allows to
> fit code into 80 lines is a bit of an art.
>
Would qpolicy be understandable? And maybe qp_ or qpol_ where something ext=
ra=20
short is necessary.

> Agreed - good point. So I am assuming something like this
>
> 	struct dccp_policy_prio {
> 		int		priority;
> 		struct timeval	lifetime;
> 	};
>
> And I think the above is already exaggerating: you asked earlier about the
> maximum number of priority bands (~8?), so I think the above can be
> reduced to "s8 priority" (-128 <=3D priority <=3D 127). Would that fit?
>
Yes, I meant to develop it in that direction. But that is merely=20
implementation of one of the policies.

> |Apart from that the questions are:
> | 1. Can we imaging a policy for which tx_qlen will not make sense? Or a
> | policy for which it will be expressed in other units than packets? For
> | example bytes?
>
> I can't think of an example at the moment, but this seems possible. The
> bytes-vs-packets question comes up more in the CCIDs than in the sending
> interface. However, there is no contradiction here: it is cleaner to keep
> the tx_qlen parameter separate from the queueing policy. The first is an
> attribute of the queue, the latter is an algorithm of what to do with the
> queue.
>
In object oriented languages attributes (tx_qlen but potentially others) an=
d=20
operations constitute a class. So they are not at all separate concepts.

> But I think there is a point in here to keep the init() function pointer:
> if you can think of a policy which depends on the queue length, this could
> be set via the init() function; and the init function would be called aft=
er
> all the setsockopt options (thereby able to override user defaults).
>
Choosing way the packets are queued by a policy based on requested queue=20
length might be an interesting feature I haven't thought about. But note th=
at=20
setsockopts for changing policy and changing queue length can be called in =

any order. If we first change the policy (hence call init()) and then chang=
e=20
queue length (which, as you propose, would not call any policy specific=20
function) then we end up with somewhat inconsistent state.

> | 2. Can we imagine a policy which will have other per policy settings
> | other than tx_qlen?
>
It seems I confused dccps_policy_data from struct dccp_sock and policy_data=
=20
from struct dccp_skb_cb...

> Yes sure, but if the policy has private data should it not rather go into
> `struct queuing_policy'.
>
Well, that is global and we don't want per policy setsockopts to mess with =

global data.

> The above is the per-skb data; the question for this struct is "what is t=
he
> minimum amount of per-skb information that needs to be stored in
> dccp_skb_cb"? And this is the same question as "what data needs to be
> passed via cmsg"?
>
Minimum? Nothing. As in policy_simple.

> So, if the struct dccp_policy_prio does not get too large, I am all for
> making it a static part of the dccp_skb_cb.
>
> The control buffer has 40 bytes, at the moment 15 bytes are already taken
> for other DCCP data, so there is room for a modest prio struct.
>
I'm not very keen on making one master struct and claiming that nobody will=
=20
ever need anything more advanced. But we could use the same mechanism by=20
which we got our 48 bytes from struct sk_buff. We could allocate a fixed=20
buffer by means of "char policy_data[16];" and each policy would cast it to=
=20
policy specific struct. Exactly the same way we cast sk_buff::cb to=20
dccp_skb_cb. Would that be ok?

> | 3. Wouldn't this void* policy_data; be useful when trying to implement a
> | more advanced policy? I mean a policy may need a place to store data
> | structures used to manage data in queue. In two already written policies
> | I don't use it, but imagine I want to organize packets not in a list but
> | in a heap-based priority queue. Where would I put this structure without
> | this kind of type generic policy and socket specific field?
>
> With regard to internal data - as per (2). But I would like to answer a
> question back: the per-skb data is only to establish an ordering amoung
> the skbs, yes? So what else apart from a number to identify a ranking
> within the list would you need? And secondly, you also have the
> doubly-linked list underlying the skb queue at your disposal, which is
> the second form of ordering.
>
Ok, never mind. I confused two fields in my own code.

> Or does your question point in another direction - using e.g. an array
> instead of a doubly-linked list, to allow implementing heaps easier?
>
No, that is policy specific discussion and I'd rather not continue it in th=
is=20
thread that already touches too many topics.

> code has almost no documentation or comments. Some documentation would ne=
ed
> to be added.
>
You certainly have a point here. I'll try to write some description when we=
=20
sort the main things out.

> What you are stating is a side effect of policy_prio that only happens wh=
en
> length(queue) >=3D tx_qlen. Otherwise, prio_push() performs skb_queue_tai=
l(),
> as does simple_push(). And I was thinking of using pop() after the call
> to ccid_hc_tx_send_packet() -- if the wait time is too long for the
> packet, it can be discarded ("popped").
>
> Actually, looking closer at _pop() I think it is not strictly necessary
> since it is an alias for skb_unlink(). Is there anything else that you
> think can be done in _pop()?
>
Imagine the packets are organized in a heap. Deleting a node from a heap is=
=20
possibly something more than skb_unlink().

> | >  * simple_{get,set}sockopt() sets TX queue length. I think this should
> | > be separate, since the length of the queue is a general attribute. Th=
is
> | > should be a main-DCCP socket option,something like e.g.
> | > DCCP_SOCKOPT_TXQLEN. It is good that you thought about it, I have hea=
rd
> | > at least one comment where someone said that it would be good to set
> | > the TX queue length on a per-socket basis. * prio_{get,set}sockopt()
> | > just return ENOPROTOOPT.
> |
> | Answer to my earlier questions about tx_qlen in particular and policy
> | specific data in general will help us decide whether this is the place
> | for getsockopt/setsockopt. But don't look at those two functions as if
> | their only purpose was to get/set tx_qlen. They are meant to be more
> | generic.
>
> Same point - I can't see any purpose served by the get/setsockopt
> function pointers here. I had to sit down and think this one over. I
> think you want to find a way of passing policy-specific data to the
> policy struct, using either sysctls, specific get/setsockopt function
> pointers.
>
Yes, I wanted to use both. sysctls for global default values and=20
set/setsockopt for individual per socket settings. And while sysctls are no=
t=20
a must have I think that get/setsockopt would be a nice thing. One could fo=
r=20
example provide userspace applications with information on how the policy i=
s=20
operating (average queue length, number of dropped/sent packets per band,=20
number of timed out packets, etc.).

> Here is an alternative suggestion:
>  * use a separate DCCP_SOCKOPT_QUEUING_POLICY_ARGS to pass arguments
>    to the policy;
But that would still require some policy specific function to process data =

passed to this DCCP_SOCKOPT_QUEUING_POLICY_ARGS sockopt, wouldn't it?

> That was the thing I missed in the patch yesterday. Currently it is
> using two fields
>
> @@ -545,6 +549,8 @@ struct dccp_sock {
>         __u8                            dccps_hc_tx_insert_options:1;
>         __u8                            dccps_server_timewait:1;
>         struct timer_list               dccps_xmit_timer;
> +       struct queuing_policy   	*dccps_policy;
> +       void                            *dccps_policy_data;
>  };
>
> I think this should be just one field for the policy, and the
> policy_data can be an internal field of `struct queueing_policy'
> (compare with struct ackvec or struct ccid).
>
Ok, I'll have a look at it. Seems reasonable.

> I don't really like these `void' pointers: this works in user-space, but
> we were having enough problems with unpredictable behaviour, so allowing
> something to be of type `anything' makes debugging harder and opens the
> door for bugs. If there is a way where you could achieve your goals witho=
ut
> void pointers, that would be great. But in some regards I have the
I don't like them either. In C++ this would be a pointer to abstract class =

(interface) or base class. But in C we have to fall back to "void*=20
priv_data;" or "char priv_data[0];" (as in struct ccid). For now I don't se=
e=20
a better way...

> impression you are still brainstorming and defining the requirements of t=
he
> problems that this interface should be designed to solve, which is why ma=
ny
> things are left open. That is fine for discussing an interface as we are
> doing here, but it is not so good to put into a test tree that is supposed
> to have a clean interface and work predictably.
>
Hopefully after this discussion the design will be good enough, working and=
=20
ready for inclusion.

> (... why per policy sysctls should be removed with along with pregister=20
> function ...)=20
>
> My suggestion is as with the other functions that are not essentially
> required: leave everything out which at the moment is not essential. If
> we find, through half a year of testing and improving, that there is a
> useful sysctl to set, it is a piece of cake to add it later.
>
Ok, agreed.

> | > When setting the TX queue length via socket options (as main-DCCP
> | > setsockopt option, not as part of the policy), the tx_qlen sysctl is
> | > indeed no longer necessary; I would be in favour of removing it, but
> | > other list members may have a different view.
> |
Seems that "other list members" got lost in our lengthy mails...

> | Seems tx_qlen is quite a specific case...
>
> There is one case which has not been mentioned so far: setting a tx_qlen
> of 0 means using in effect an "infinite" TX queue. This is something to
> consider for the queueing policy - whether it works with (in theory)
> infinite queues, or better with a fixed (or policy-specific) queue size.
>
I don't see how ability of a certain policy to work with "infinite" queues =

should affect the main design. This seems to be a thing to consider when=20
writing a specific policy.
My point about tx_qlen is that it affects how a policy works and should=20
therefore be policy specific setting managed by the policy. For me it=20
logically belongs to a policy. The main weakness of this design is that=20
tx_qlen exists in all policies I can think of...
--=20
Regards,
Tomasz Grobelny
