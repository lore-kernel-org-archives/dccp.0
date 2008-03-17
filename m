From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 17 Mar 2008 22:38:27 +0000
Subject: Re: packet priorities
Message-Id: <200803172338.28356.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 17 of March 2008, Gerrit Renker napisa=B3:
> Hi Tomasz,
>
> first of all - the idea and the basic design is _great_ and would like
> to see the wheels in motion to get this into the test tree real soon.
>
Nice to hear that. It seems that in part I may have made my code too generi=
c.

> I have some suggestions below for streamlining the interface.
> Details are below, the main points in brief are
>  * format needs some tidying up (naming convention, formatting);
I find indentation and braces guidelines disgusting, but ok, I understand i=
t=20
has to be consistent :-/

>  * TX queue length should be a standalone socket option, not as
>    part of the policy (but agree that the tx_qlen sysctl could go);
I wasn't sure if it should be policy specific or not. So I implemented a mo=
re=20
generic solution. See my further comments about tx_qlen.

>  * there should not be per-policy sysctls - these are for global options
>    and policies are changed per socket;
I see two arguments here:
1. sysctls should be global. And they are a default for all new sockets usi=
ng=20
that policy. Which means that they are in fact global.
2. sysctls should not affect only one=20
policy. /proc/sys/net/dccp/default/ack_ratio on the other hand seems to be =

ccid2 specific.

per-policy sysctls are only about default values that are used for per sock=
et=20
policy instance.

>  * I think there should not be a sysctl for the policy, since each
>    policy has specific dependencies, so that a user-changeable sysctl
>    will just create confustion;
In a sense you are right. In my code changing default policy to 1 makes no =

sense without modifying the application. But we could imagine several=20
policies that have the same interface but slightly different behaviour...

>  * some of the functions in the table might be rationalised away, if
>    they are not doing much.
>
<irony>"rationalize away"? You simply want to kill them! I got quite used t=
o=20
them over the last few days, so I'll fight hard for my functions ;-) </iron=
y>

> Will you be sending this as a patch? I have locally viewed the code by
> first checking out the SVN. For the test tree I need patch format with
> your signed-off.
>
When the code will be more or less correct I will send a patch in required =

format.

> Please check through the comments below.
>
> -----------------
> General comments:
> -----------------
> I first couldn't see the benefit of using both socket options and cmsg
> data. But it is clearly better than doing the policy on a per-packet basi=
s,
> and it also simplifies the cmsg data (next section).
>
> With regard to filenames (policy.[ch]) it would be better to have a more
> specific name (e.g. send_prios.[ch]), since this avoids confusion with
> other parts. It would be great to have small description at the top of the
> header (and maybe source) file.
>
send_prio would be a bit misleading since priorities are only in one of two=
=20
policies. But it could be something like queuing_policy{_simple,_prio}.[ch]=
=20
Would that be ok?

> ------------------------------------------
> The data to pass on to the socket via cmsg
> ------------------------------------------
> 	struct dccp_policy_prio
> 	{
> 	       u8 priority;
> 	};
>
> If the interpretation of the priority field depends on the socket option
> then why not simply use
>
> 	int priority;
>
> where `priority' can be
> 	* a preference value implying an ordering;
> 	* a positive time-to-live in milliseconds;
> 	* ... (probably also using a number)?
>
I thought that using a structure would be a cleaner design. Especially when=
=20
one policy would use both time-to-live and priority. I didn't implement=20
time-to-live (or expiry time) just because it wasn't my priority for now.

> Using a signed number allows to assign negative priorities, maybe this is
> useful (as in the `nice' command).
>
In `nice' command we have ranges reserved for superuser and that's why ther=
e=20
are negative and positive values. Here we don't as packets in one socket=20
cannot be sent by both ordinary user and superuser. But I have nothing=20
against signed value, it doesn't hurt.

> What do you think - is it necessary to have richer semantics? As far as I
> can see, a sufficiently-large integer number already has quite a rich
> semantics.
>
I see a structure as cleaner design which would allow us later to add more =

fields without the need to change userspace source code.

> ----------------
> The per-skb data
> ----------------
> @ -332,6 +337,7 @@ struct dccp_skb_cb {
>         __u16 dccpd_opt_len;
>         __u64 dccpd_seq;
>         __u64 dccpd_ack_seq;
> +       void* policy_data;
>  };
>
> For the prio policy, the policy_data is the dccp_policy_prio struct, for
> the simple policy it is the TX queue length. There is another comment
> regarding the TX queue length below, I believe it is better to set the
> queue length per-socket: there will only be one policy on the socket at o=
ne
> time, and the queue length is a separate attribute.
> My suggestion is to simply add a `dccp_policy_prio' field. If a number is
> sufficient, this would be
>
> @ -332,6 +337,7 @@ struct dccp_skb_cb {
>         __u16 dccpd_opt_len;
>         __u64 dccpd_seq;
>         __u64 dccpd_ack_seq;
> +       int   dccp_policy_prio;
>  };
>
> In this way, kmalloc/kfree/memcpy would not be required.
>
Did you mean tx_qlen instead of dccp_policy_prio? Apart from that the=20
questions are:
1. Can we imaging a policy for which tx_qlen will not make sense? Or a poli=
cy=20
for which it will be expressed in other units than packets? For example=20
bytes?
2. Can we imagine a policy which will have other per policy settings other =

than tx_qlen?
3. Wouldn't this void* policy_data; be useful when trying to implement a mo=
re=20
advanced policy? I mean a policy may need a place to store data structures =

used to manage data in queue. In two already written policies I don't use i=
t,=20
but imagine I want to organize packets not in a list but in a heap-based=20
priority queue. Where would I put this structure without this kind of type =

generic policy and socket specific field?

> -------------
> The interface
> -------------
> First of all - the idea is great and I really like the interface. I think
> that some functions can be "rationalised" to make the interface leaner and
> smaller (comments below), but that does not change the fact that the idea
> of having a modular interface is excellent.
>
> struct queuing_policy
> +{
> +       unsigned char policy_id;
> +       /* Interface Routines */
> +       int (*pregister)(void);
> +       int (*init)(struct sock *sk);
> +       void (*push)(struct sock *sk, struct sk_buff *skb, void* control,
> __kernel_size_t controllen); +       int (*full)(struct sock *sk);
> +       struct sk_buff* (*top)(struct sock *sk);
> +       void (*pop)(struct sock *sk, struct sk_buff *skb);
> +       int (*setsockopt)(struct sock *sk, int optname, int optval);
> +       int (*getsockopt)(struct sock *sk, int optname, int* optval);
> +       int (*destroy)(struct sock *sk);
> +};
>
> The push(), full(), top(), pop(), init(), and destroy() functions are
> clear. The idea of using stack semantics is just great. It even allows one
> to drop an old packet (via pop()) when the CCID has waited too long. I
> really hope to see this soon in the tree.
>
In fact it's push() that discards data in policy_prio at least :-) pop() is=
=20
designed to discard only packets that were actually sent.

> I think that the get/setsockopt() functions should be part of the main DC=
CP
> interface, not function pointers in a loadable unit, because:
>  * this makes the interface simpler and avoids "case 256 ... 511";
Simpler? Maybe. But at the same time less generic. Moreover I find nothing =

wrong with "case 256 ... 511", similar code is used for getting info from=20
specific CCIDs so I followed the same pattern.

>  * simple_{get,set}sockopt() sets TX queue length. I think this should be
> separate, since the length of the queue is a general attribute. This shou=
ld
> be a main-DCCP socket option,something like e.g. DCCP_SOCKOPT_TXQLEN. It =
is
> good that you thought about it, I have heard at least one comment where
> someone said that it would be good to set the TX queue length on a
> per-socket basis. * prio_{get,set}sockopt() just return ENOPROTOOPT.
>
Answer to my earlier questions about tx_qlen in particular and policy speci=
fic=20
data in general will help us decide whether this is the place for=20
getsockopt/setsockopt. But don't look at those two functions as if their on=
ly=20
purpose was to get/set tx_qlen. They are meant to be more generic.

> The other comment is the constructor: I think one of init() (preferable)
> and pregister() is sufficient, but actually I am wondering whether
> constructors/destructors are needed? Both destroy() functions are empty, =
so
> is prio_init(), and simple_init() allocates an integer for the tx_qlen
> (please see separate comment regarding TX queue length).
>
The tx_qlen is a completely different and possibly a very specific thing=20
mentioned several times already. As for empty simple_destroy: well there=20
probably should be a kfree(dp->dccps_policy_data); there.

> The pregister() functions currently both register sysctls. This is not a
> good idea, since sysctls are a global policy, but in your code they are
> loaded/unloaded on a per-socket basis. This means you would have a clash
> when using two different sockets with different policies: one would try to
> load "dccp_prio_simple" sysctls and the other would try to load
> "dccp_prio_other" sysctls - so they would "bite" each other. But when
> taking the sysctls out of the pregister() functions, there is little left;
> as a result register_queuing_policies() (and the call in dccp_sysctl_init)
> could also be omitted.
>
I haven't checked that in practice but there should be no clash. The pregis=
ter=20
functions are executed in the same place where all other dccp sysctls are=20
registered. Which is I believe on dccp module load. And pregister functions=
=20
are not socket specific - note that they don't get struct sock *sk as=20
parameter (as opposed to init which is socket specific).

> If there is use for a constructor/destructor function, they could be
> declared as null functions with wrappers which test whether the functions
> are non-null, as Arnaldo has done this in net/dccp/ccid.h.
>
Ok, that might be nice.

> Otherwise, if the constructors are not used (i.e. if there is no
> policy-specific private data to allocate and de-allocate), I think it wou=
ld
> be better to not declare pregister(), init(), and destroy() at the moment.
> One can always add more functions later.
>
I think that policy-specific private data (and so init and destroy function=
s)=20
could be useful for some policies. Note that standard sk_write_queue is not=
 a=20
very sophisticated data structure and some policies might want to use=20
something more advanced to manage packets (to make it possibly faster).

> --------------------
> The sysctl interface
> --------------------
>
> @@ -83,9 +84,9 @@ static struct ctl_table dccp_default_tab
>                 .proc_handler   =3D proc_dointvec,
>         },
>         {
> -               .procname       =3D "tx_qlen",
> -               .data           =3D &sysctl_dccp_tx_qlen,
> -               .maxlen         =3D sizeof(sysctl_dccp_tx_qlen),
> +               .procname       =3D "policy",
> +               .data           =3D &sysctl_dccp_policy,
> +               .maxlen         =3D sizeof(sysctl_dccp_policy),
>                 .mode           =3D 0644,
>                 .proc_handler   =3D proc_dointvec,
>         },
>
> I think it is better to keep the sysctl for the default TX queue length. =
To
> me, having a sysctl for the default policy is of very little merit. This =
is
> because each policy will require specific per-socket data. That is, when
> setting a "timeout policy", then the socket will want timeout data and wi=
ll
> malfunction if it doesn't get the timeout data (or `prio' data if the user
> selected prio_policy). Thus, I think that policies should only be set via
> socket options.
>
You almost convinced me. ;-) I think there are cases where this could be=20
useful but you are right in that it would create more confusion that it's=20
worth.

> When setting the TX queue length via socket options (as main-DCCP
> setsockopt option, not as part of the policy), the tx_qlen sysctl is inde=
ed
> no longer necessary; I would be in favour of removing it, but other list
> members may have a different view.
>
Seems tx_qlen is quite a specific case...

> --------------------
> Some specific things
> --------------------
>
> sizeof(queuing_policies)/sizeof(struct queuing_policy*)
> =3D> could use ARRAY_SIZE(queuing_policies);
>
> struct queuing_policy
> +{
> +       int (*full)(struct sock *sk);
> =3D> If it only returns "yes" or "no", make it
> 	bool (*full) (struct sock *sk);
>
> ----------------
> Format comments:
> ----------------
> when you send patches, the first/obvious things that people will look at
> are: * kernel coding style (Documentation/Documentation/CodingStyle)
>  * items from the Documentation/SubmitChecklist
>  * very useful information is also in Documentation/SubmittingPatches
>  * whitespace (no trailing whitespace, no spaces before tabs)
> I found that scripts/checkpatch.pl is a very useful tool with regard to t=
he
> above.
Ok, thanks for these comments.
--=20
Regards,
Tomasz Grobelny
