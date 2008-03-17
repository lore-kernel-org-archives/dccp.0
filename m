From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 17 Mar 2008 11:53:08 +0000
Subject: Re: packet priorities
Message-Id: <20080317115308.GA13171@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Tomasz,

first of all - the idea and the basic design is _great_ and would like
to see the wheels in motion to get this into the test tree real soon. 

I have some suggestions below for streamlining the interface. 
Details are below, the main points in brief are
 * format needs some tidying up (naming convention, formatting);
 * TX queue length should be a standalone socket option, not as
   part of the policy (but agree that the tx_qlen sysctl could go);
 * there should not be per-policy sysctls - these are for global options
   and policies are changed per socket;
 * I think there should not be a sysctl for the policy, since each 
   policy has specific dependencies, so that a user-changeable sysctl
   will just create confustion;
 * some of the functions in the table might be rationalised away, if
   they are not doing much.

Will you be sending this as a patch? I have locally viewed the code by
first checking out the SVN. For the test tree I need patch format with
your signed-off.

Please check through the comments below.

-----------------
General comments:
-----------------
I first couldn't see the benefit of using both socket options and cmsg data. But
it is clearly better than doing the policy on a per-packet basis, and it also
simplifies the cmsg data (next section).

With regard to filenames (policy.[ch]) it would be better to have a more
specific name (e.g. send_prios.[ch]), since this avoids confusion with other
parts. It would be great to have small description at the top of the header
(and maybe source) file.

I am sure Arnaldo can give better advice on this - also with regard to function
naming conventions. The `dccp_queue_xxx' you are using in some parts is useful
for a naming scheme.

------------------------------------------
The data to pass on to the socket via cmsg
------------------------------------------
	struct dccp_policy_prio
	{
	       u8 priority;
	};

If the interpretation of the priority field depends on the socket option
then why not simply use

	int priority;

where `priority' can be
	* a preference value implying an ordering;
	* a positive time-to-live in milliseconds;
	* ... (probably also using a number)?

Using a signed number allows to assign negative priorities, maybe this is
useful (as in the `nice' command).

What do you think - is it necessary to have richer semantics? As far as I can see, a
sufficiently-large integer number already has quite a rich semantics.


----------------
The per-skb data
----------------
@ -332,6 +337,7 @@ struct dccp_skb_cb {
        __u16 dccpd_opt_len;
        __u64 dccpd_seq;
        __u64 dccpd_ack_seq;
+       void* policy_data;
 };

For the prio policy, the policy_data is the dccp_policy_prio struct, for the simple policy it is
the TX queue length. There is another comment regarding the TX queue length below, I believe it is
better to set the queue length per-socket: there will only be one policy on the socket at one time,
and the queue length is a separate attribute.
My suggestion is to simply add a `dccp_policy_prio' field. If a number is sufficient, this would be

@ -332,6 +337,7 @@ struct dccp_skb_cb {
        __u16 dccpd_opt_len;
        __u64 dccpd_seq;
        __u64 dccpd_ack_seq;
+       int   dccp_policy_prio; 
 };

In this way, kmalloc/kfree/memcpy would not be required.


-------------
The interface
-------------
First of all - the idea is great and I really like the interface. I think that some functions can be
"rationalised" to make the interface leaner and smaller (comments below), but that does not change the
fact that the idea of having a modular interface is excellent.

struct queuing_policy
+{
+       unsigned char policy_id;
+       /* Interface Routines */
+       int (*pregister)(void);
+       int (*init)(struct sock *sk);
+       void (*push)(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen);
+       int (*full)(struct sock *sk);
+       struct sk_buff* (*top)(struct sock *sk);
+       void (*pop)(struct sock *sk, struct sk_buff *skb);
+       int (*setsockopt)(struct sock *sk, int optname, int optval);
+       int (*getsockopt)(struct sock *sk, int optname, int* optval);
+       int (*destroy)(struct sock *sk);
+};

The push(), full(), top(), pop(), init(), and destroy() functions are clear. The idea of using stack 
semantics is just great. It even allows one to drop an old packet (via pop()) when the CCID has waited
too long. I really hope to see this soon in the tree.

I think that the get/setsockopt() functions should be part of the main DCCP interface, not
function pointers in a loadable unit, because:
 * this makes the interface simpler and avoids "case 256 ... 511";
 * simple_{get,set}sockopt() sets TX queue length. I think this should be separate, since the
   length of the queue is a general attribute. This should be a main-DCCP socket option,something like
   e.g. DCCP_SOCKOPT_TXQLEN. It is good that you thought about it, I have heard at least one comment
   where someone said that it would be good to set the TX queue length on a per-socket basis. 
 * prio_{get,set}sockopt() just return ENOPROTOOPT.

The other comment is the constructor: I think one of init() (preferable) and pregister() is
sufficient, but actually I am wondering whether constructors/destructors are needed?
Both destroy() functions are empty, so is prio_init(), and simple_init() allocates an integer for
the tx_qlen (please see separate comment regarding TX queue length).

The pregister() functions currently both register sysctls. This is not a good idea, since sysctls
are a global policy, but in your code they are loaded/unloaded on a per-socket basis. This means you
would have a clash when using two different sockets with different policies: one would try to load
"dccp_prio_simple" sysctls and the other would try to load "dccp_prio_other" sysctls - so they would
"bite" each other. But when taking the sysctls out of the pregister() functions, there is little left;
as a result register_queuing_policies() (and the call in dccp_sysctl_init) could also be omitted.

If there is use for a constructor/destructor function, they could be declared as null functions with
wrappers which test whether the functions are non-null, as Arnaldo has done this in net/dccp/ccid.h.

Otherwise, if the constructors are not used (i.e. if there is no policy-specific private data to
allocate and de-allocate), I think it would be better to not declare pregister(), init(), and destroy()
at the moment. One can always add more functions later.

--------------------
The sysctl interface
--------------------

@@ -83,9 +84,9 @@ static struct ctl_table dccp_default_tab
                .proc_handler   = proc_dointvec,
        },
        {
-               .procname       = "tx_qlen",
-               .data           = &sysctl_dccp_tx_qlen,
-               .maxlen         = sizeof(sysctl_dccp_tx_qlen),
+               .procname       = "policy",
+               .data           = &sysctl_dccp_policy,
+               .maxlen         = sizeof(sysctl_dccp_policy),
                .mode           = 0644,
                .proc_handler   = proc_dointvec,
        },

I think it is better to keep the sysctl for the default TX queue length. To me, having a sysctl for the
default policy is of very little merit. This is because each policy will require specific per-socket data.
That is, when setting a "timeout policy", then the socket will want timeout data and will malfunction if
it doesn't get the timeout data (or `prio' data if the user selected prio_policy). Thus, I think that 
policies should only be set via socket options. 

When setting the TX queue length via socket options (as main-DCCP setsockopt option, not as part of the
policy), the tx_qlen sysctl is indeed no longer necessary; I would be in favour of removing it, but other
list members may have a different view.


--------------------
Some specific things
--------------------

sizeof(queuing_policies)/sizeof(struct queuing_policy*)
=> could use ARRAY_SIZE(queuing_policies);


struct queuing_policy
+{
+       int (*full)(struct sock *sk);
=> If it only returns "yes" or "no", make it
	bool (*full) (struct sock *sk);

----------------
Format comments: 
----------------
when you send patches, the first/obvious things that people will look at are:
 * kernel coding style (Documentation/Documentation/CodingStyle)
 * items from the Documentation/SubmitChecklist
 * very useful information is also in Documentation/SubmittingPatches
 * whitespace (no trailing whitespace, no spaces before tabs)
I found that scripts/checkpatch.pl is a very useful tool with regard to the above.
