From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 10:47:29 +0000
Subject: Re: [DCCP]: Add priority queuing policy
Message-Id: <20080407104729.GQ6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.44319.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.44319.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Tomasz Grobelny:
> Gerrit Renker pisze:
>> Please revise this patch with regard to CodingStyle -- checkpatch gave
>> 38 errors here.
>>
>> | --- a/net/dccp/dccp.h
>> | +++ b/net/dccp/dccp.h
>> | @@ -330,10 +330,16 @@ struct dccp_skb_cb {
>> |  	__u16 dccpd_opt_len;
>> |  	__u64 dccpd_seq;
>> |  	__u64 dccpd_ack_seq;
>> | +	char  dccpd_policy[16];
>> |  };
>> |  |  #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb 
>> *)&((__skb)->cb[0]))
>> |  | +struct dccp_policy_prio {
>> | +	s8	priority;
>> | +};
>> | +#define SKB_PRIO(__skbcb) ((struct dccp_policy_prio *)&((__skbcb)->dccpd_policy[0]))
>> | +
>> There is an indirection here which is problematic:
>>  * it pre-allocates 16 bytes but currently only uses one byte
>>  * with regard to the recent patch for IPv4/v6 parameters, the skb_cb
>>    space gets smaller, and there is no test such as BUILD_BUG_ON
>>  * the element should be the struct (can remain anonymous), so there would not be
>>    the double-indirection in the SKB_PRIO typecast (which is also too long)
>>
> But the whole point is that this struct can be different for different  
> queuing policies. Statically allocating fixed amount of bytes is one way  
> (as for me it doesn't have to be 16), using a void pointer is second one  
> and I don't see the third way if qpolicy should be able to define its  
> own additional per-packet information. But I'm open to ideas...
> -- 
Statically allocating is not good. First, the magic number of 16 bytes
is easily forgotten, in particular when someone later adds fields to the
struct. Second, it takes a lot of room from the cb array which someone
else may want to use. 

What I meant in the above is to declare it like this:

@@ -330,10 +330,16 @@ struct dccp_skb_cb {
  	__u16				dccpd_opt_len;
  	__u64				dccpd_seq;
  	__u64				dccpd_ack_seq;
+	struct dccp_policy_prio		dccpd_prio;

It does not matter that different queueing policies will not use all
fields of the struct. The same happens to other fields in dccp_skb_cb:
opt_len, ack_seq etc. are also not always used and yet the compiler
will catch all type errors for them (which it won't with indirect
typecasting).

To have it perfect, we should use something like the BUILD_BUG_ON used
in the similar patch for the IPv4/6 parameters from Friday.

Last - I can't think of a wi{de,ld} variety of degrees of possible
fields for dccp_policy_prio -- apart from the timeout which Ian's 
patch set had implemented.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

