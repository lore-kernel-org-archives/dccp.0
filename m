From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 10:59:35 +0000
Subject: Re: [DCCP]: Allow applications to change tx_qlen
Message-Id: <20080407105935.GR6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.58295.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.58295.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> | --- a/net/dccp/proto.c
>> | +++ b/net/dccp/proto.c
>> | @@ -547,6 +547,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
>> |  	case DCCP_SOCKOPT_QPOLICY_ID:
>> |  		err = dccp_qpolicy_set_id(sk, val);
>> |  		break;
>> | +	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
>> | +		err = dccp_qpolicy_set_txqlen(sk, val);
>> | +		break;
>> Not necessary to declare dccp_qpolicy_set_txqlen to return an int (0):
>> err is initialised with err = 0 above, so can simply write
>> 		dccp_qpolicy_set_txqlen(sk, val);
>> 		break;
>> or - I can't think of any other place to use this, so  a function may not be needed:
>>
>> 		dccp_sk(sk)->dccps_qpolicy->qpol_txqlen = len;
>> 		break;
>>
> That's what I originally did. But then I thought that:
> 1. This way is prettier and more consistent. Which is of course very  
> subjective.
> 2. Later we might want to return an error when changing tx_qlen for an  
> already initialized policy wouldn't make sense or would require  
> additional code complexity. This is exactly the case you mentioned in  
> our previous discussion: choosing algorithms based on queue length.
>
The second point is good -- as it is not immediately obviously from the
code, it would be good to have it as a comment.


>> | -	if(sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)
>> | +	if(sk->sk_write_queue.qlen >= tx_qlen)
>> This is good - but should keep in mind to deprecate sysctl_dccp_tx_qlen
>> in a future patch, since it is now "unemployed".
>>
> No, sysctl_dccp_tx_qlen still acts as a default:
I still think that it would be good to deprecate the sysctl and replace
it with a default value. But it is not important now.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

