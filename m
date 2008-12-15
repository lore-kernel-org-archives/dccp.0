From: walter harms <wharms@bfs.de>
Date: Mon, 15 Dec 2008 14:23:44 +0000
Subject: Re: [PATCH 4/5] dccp: Initialisation and type-checking of feature
Message-Id: <49466870.3010202@bfs.de>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-5-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



Arnaldo Carvalho de Melo schrieb:
> Em Sat, Dec 13, 2008 at 02:41:24PM +0100, Gerrit Renker escreveu:
>> This patch takes care of initialising and type-checking sysctls related to
>> feature negotiation. Type checking is important since some of the sysctls
>> now directly act on the feature-negotiation process.
>>
>> The sysctls are initialised with the known default values for each feature.
>> For the type-checking the value constraints from RFC 4340 are used:
>>
>>  * Sequence Window uses the specified Wmin2, the maximum is ulong (4 bytes),
>>    tested and confirmed that it works up to 4294967295 - for Gbps speed;
>>  * Ack Ratio is between 0 .. 0xffff (2-byte unsigned integer);
>>  * CCIDs are between 0 .. 255;
>>  * request_retries, retries1, retries2 also between 0..255 for good measure;
>>  * tx_qlen is checked to be non-negative;
>>  * sync_ratelimit remains as before.
>>
>> Further changes:
>> ----------------
>> Performed s@sysctl_dccp_feat@sysctl_dccp@g since the sysctls are now in feat.c.
>>
>> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
>> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
>> ---
>>  include/linux/dccp.h |    8 --------
>>  net/dccp/dccp.h      |    3 ---
>>  net/dccp/feat.c      |   11 ++++++++---
>>  net/dccp/feat.h      |    8 ++++++++
>>  net/dccp/options.c   |    4 ----
>>  net/dccp/sysctl.c    |   43 ++++++++++++++++++++++++++++++-------------
>>  6 files changed, 46 insertions(+), 31 deletions(-)
>>
>> --- a/net/dccp/feat.h
>> +++ b/net/dccp/feat.h
>> @@ -100,6 +100,13 @@ struct ccid_dependency {
>>  	u8	val;
>>  };
>>  
>> +/*
>> + * Sysctls to seed defaults for feature negotiation
>> + */
>> +extern unsigned long sysctl_dccp_sequence_window;
>> +extern int	     sysctl_dccp_rx_ccid;
>> +extern int	     sysctl_dccp_tx_ccid;
>> +
>>  #ifdef CONFIG_IP_DCCP_DEBUG
>>  extern const char *dccp_feat_typename(const u8 type);
>>  extern const char *dccp_feat_name(const u8 feat);
>> @@ -114,6 +121,7 @@ static inline void dccp_feat_debug(const u8 type, const u8 feat, const u8 val)
>>  #endif /* CONFIG_IP_DCCP_DEBUG */
>>  
>>  extern int  dccp_feat_init(struct sock *sk);
>> +extern void dccp_feat_initialise_sysctls(void);
>>  extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
>>  				  u8 const *list, u8 len);
>>  extern int  dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val);
>> --- a/net/dccp/feat.c
>> +++ b/net/dccp/feat.c
>> @@ -25,6 +25,11 @@
>>  #include "ccid.h"
>>  #include "feat.h"
>>  
>> +/* feature-specific sysctls - initialised to the defaults from RFC 4340, 6.4 */
>> +unsigned long	sysctl_dccp_sequence_window __read_mostly = 100;
>> +int		sysctl_dccp_rx_ccid	    __read_mostly = 2,
>> +		sysctl_dccp_tx_ccid	    __read_mostly = 2;
>> +
>>  /*
>>   * Feature activation handlers.
>>   *
>> @@ -1146,7 +1151,7 @@ int dccp_feat_init(struct sock *sk)
>>  
>>  	/* Non-negotiable (NN) features */
>>  	rc = __feat_register_nn(fn, DCCPF_SEQUENCE_WINDOW, 0,
>> -				    sysctl_dccp_feat_sequence_window);
>> +				    sysctl_dccp_sequence_window);
>>  	if (rc)
>>  		return rc;
>>  
>> @@ -1177,8 +1182,8 @@ int dccp_feat_init(struct sock *sk)
>>  	if (ccid_request_modules(tx.val, tx.len))
>>  		goto free_ccid_lists;
>>  
>> -	if (!dccp_feat_prefer(sysctl_dccp_feat_tx_ccid, tx.val, tx.len) ||
>> -	    !dccp_feat_prefer(sysctl_dccp_feat_rx_ccid, rx.val, rx.len))
>> +	if (!dccp_feat_prefer(sysctl_dccp_tx_ccid, tx.val, tx.len) ||
>> +	    !dccp_feat_prefer(sysctl_dccp_rx_ccid, rx.val, rx.len))
>>  		goto free_ccid_lists;
>>  
>>  	rc = __feat_register_sp(fn, DCCPF_CCID, true, false, tx.val, tx.len);
>> --- a/net/dccp/dccp.h
>> +++ b/net/dccp/dccp.h
>> @@ -95,9 +95,6 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
>>  extern int  sysctl_dccp_request_retries;
>>  extern int  sysctl_dccp_retries1;
>>  extern int  sysctl_dccp_retries2;
>> -extern int  sysctl_dccp_feat_sequence_window;
>> -extern int  sysctl_dccp_feat_rx_ccid;
>> -extern int  sysctl_dccp_feat_tx_ccid;
>>  extern int  sysctl_dccp_tx_qlen;
>>  extern int  sysctl_dccp_sync_ratelimit;
>>  
>> --- a/include/linux/dccp.h
>> +++ b/include/linux/dccp.h
>> @@ -355,14 +355,6 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
>>  	return __dccp_hdr_len(dccp_hdr(skb));
>>  }
>>  
>> -
>> -/* initial values for each feature */
>> -#define DCCPF_INITIAL_SEQUENCE_WINDOW		100
>> -#define DCCPF_INITIAL_ACK_RATIO			2
>> -#define DCCPF_INITIAL_CCID			DCCPC_CCID2
>> -/* FIXME: for now we're default to 1 but it should really be 0 */
>> -#define DCCPF_INITIAL_SEND_NDP_COUNT		1
>> -
>>  /**
>>   * struct dccp_request_sock  -  represent DCCP-specific connection request
>>   * @dreq_inet_rsk: structure inherited from
>> --- a/net/dccp/options.c
>> +++ b/net/dccp/options.c
>> @@ -23,10 +23,6 @@
>>  #include "dccp.h"
>>  #include "feat.h"
>>  
>> -int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
>> -int sysctl_dccp_feat_rx_ccid	      = DCCPF_INITIAL_CCID;
>> -int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
>> -
>>  u64 dccp_decode_value_var(const u8 *bf, const u8 len)
>>  {
>>  	u64 value = 0;
>> --- a/net/dccp/sysctl.c
>> +++ b/net/dccp/sysctl.c
>> @@ -18,55 +18,72 @@
>>  #error This file should not be compiled without CONFIG_SYSCTL defined
>>  #endif
>>  
>> +/* Boundary values */
>> +static int		zero     = 0,
>> +			u8_max   = 0xFF;
> 
> I wonder if these aren't available for wider use... some files have it:
> 
> ./kernel/sysctl.c
> ./fs/inotify_user.c
> ./net/sunrpc/xprtrdma/transport.c
> ./net/ipv4/ip_fragment.c
> ./net/ipv4/sysctl_net_ipv4.c
> ./net/sctp/sysctl.c (well, this one also does the not needed '= 0' :) */
> 
> static int zero;
> 
> Some others, such as ./net/netrom/sysctl_net_netrom.c, could also use it
> 
> And one, etc, and it seems some people are even more crazy about saving
> some bytes:
> 
> /* Constants used for minimum and  maximum */
> #if defined(CONFIG_HIGHMEM) || defined(CONFIG_DETECT_SOFTLOCKUP)
> static int one = 1;
> #endif
> 
> Unsure if the cost of exporting this to modules will do us good tho...
> 
> Perhaps some janitor may be interested in doing some measurements and
> looking at u8_max (int_max, etc) too? :-)
> 
> Other than that:
> 

busybox has replace static int with enum's to save bytes. i guess this is the way to save bytes :)

re,
 wh
