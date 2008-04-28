From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Apr 2008 15:08:19 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: External interface changes
Message-Id: <20080428150819.GA27604@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080424220704.0483DBC12@poczta.oswiecenia.net>
In-Reply-To: <20080424220704.0483DBC12@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Separate internal (in-kernel) storage of per packet data from external
| interface (which is now an easily extensible structure).
| 
I can see your point, there is an alternative to realise what you are
aiming to do, suggestions/comments are below.


| --- a/include/linux/dccp.h
| +++ b/include/linux/dccp.h
| @@ -98,6 +98,15 @@ struct dccp_hdr_reset {
|  					dccph_reset_data[3];
|  };
|  
| +/**
| + * struct dccp_qpolicy_prio_info - information used by prio queuing policy
| + *
| + * @priority - packet priority (bigger value sent first)
| + */
| +struct dccp_qpolicy_prio_info {
| +	__s8	priority;
| +};
| +
|  enum dccp_pkt_type {
|  	DCCP_PKT_REQUEST = 0,
|  	DCCP_PKT_RESPONSE,

| --- a/net/dccp/proto.c
| +++ b/net/dccp/proto.c
| @@ -706,7 +706,7 @@ int compat_dccp_getsockopt(struct sock *sk, int level, int optname,
|  EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
|  #endif
|  
| -static int dccp_msghdr_parse(struct msghdr *msg, __u32 **priority)
| +static int dccp_msghdr_parse(struct msghdr *msg, struct cmsghdr **cmsg_qpolicy)
|  {
|  	struct cmsghdr *cmsg = CMSG_FIRSTHDR(msg);
|  
| @@ -721,9 +721,7 @@ static int dccp_msghdr_parse(struct msghdr *msg, __u32 **priority)
|  
|  		switch (cmsg->cmsg_type) {
|  		case DCCP_SCM_PRIORITY:
| -			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u32)))
| -				return -EINVAL;
| -			*priority = (__u32 *)CMSG_DATA(cmsg);
| +			*cmsg_qpolicy = cmsg;
|  			break;
|  		default:
|  			return -EINVAL;
Here the cmsg is exported to any current qpolicy. The disadvantages are	that
 * there is no longer any length check, the functions using this interface
   have in the worst case no idea how much the user wanted to pass, so
   this is dangerous (compare also RFC 3542, 20.2);
 * the separation-of-concerns becomes unclear: now part of the parsing is done
   in dccp_msg_hdr_parse() and another part in some of the qpolicy_xxx_push()
   routines, so one routine does part of the work of another;
 * each qpolicy_xxx_push() routine needs to have a cmsghdr* argument even if it is
   not used.

It is however possible to reach the same goal with just a small modification:
 * so far only one SCM message (DCCP_SCM_PRIORITY) has been defined;
 * maintainers generally accepted the use of skb->priority while on layer 4;
 * hence for all sub-variants of a "prio" policy (strict/partial orderings),
   one can use DCCP_SCM_PRIORITY, in combination with skb->priority;
 * for different policies, define a different DCCP_SCM_xxx message and
   store the cmsg data in a different field (to be decided);
 * this has the advantage that type/length checking is all in one place,
   so that the qpolicy routines need to do qpolicy only.

| --- a/net/dccp/qpolicy.c
| +++ b/net/dccp/qpolicy.c
| @@ -57,8 +58,13 @@ static struct sk_buff *qpolicy_prio_worst_skb(struct sock *sk)
|  	return worst;
|  }
|  
| -static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb)
| +static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb,
| +				struct cmsghdr *cmsg)
|  {
| +	struct dccp_qpolicy_prio_info info;
| +	memcpy(&info, CMSG_DATA(cmsg), min(cmsg->cmsg_len, sizeof(info)));
That is the problem I see - `info' could end up with garbled data, if the user had
accidentally passed `u32' instead of CMSG_LEN(sizeof priority). 

The CMSG_LEN() ensures an additional check - that the user is in fact using
proper encapsulation via CMSG_xxx macros and not via msg_control/msg_controllen
directly. The latter leads to hard-to-debug problems: in my case, I found
this works - by accident - on 32-bit Intel, but will fail on 64-bit computers
in compatibility mode.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

