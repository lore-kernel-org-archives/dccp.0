From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 19 Jun 2008 11:42:00 +0000
Subject: Re: QUESTION : Feature length about the non-negotiable feature
Message-Id: <485A4608.7080309@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <48579530.4010807@cn.fujitsu.com>
In-Reply-To: <48579530.4010807@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The RFC doesn't really require that you reset the connection just if the 
length is strange.  Accepting valid values expressed in an strange length, but 
generating only the required lengths, seems like a good application of the TCP 
robustness principle ("be conservative in what you do,  be liberal in what you 
accept from others", explicitly in RFC4340 3.6).

The discussion on whether Sequence Window should be variable-length begins here:

http://www.ietf.org/mail-archive/web/dccp/current/msg01257.html
search for "MW5: Section 7.5.2, second paragraph"

The two followups have a bit more.

Magnus Westerlund was one of the IETF's expert reviewers for DCCP; his opinion 
carried some weight.  Probably I folded too early (I thought the extra 
"complexity" of a variable-length option wouldn't matter, and the option might 
occur frequently).

One solution might be a "dccp_pedantic" sysctl, defaulting to 0, where Linux 
DCCP is guaranteed to be RFC compliant only if "dccp_pedantic" is 1.  (And 
Sequence Window is variable-length if "dccp_pedantic" is 0.)

Eddie


Gerrit Renker wrote:
>>> This has been tested, I will post the changelog for the test tree
>>> shortly and upload the amended tree. I would be grateful if you could
>>> give this a spin with your test cases.
>>>
>>>   
>> With the patch, it is OK for send non-negotiable features. But not valid  
>> for check invalid value when recv.
>>
>>
> Thank you for testing. I don't understand your second sentence: all NN
> options are value-checked, i.e. if you try a Sequence Window of less
> than 32 or greater than 2^46-1, the connection should be reset.
> Likewise, Ack Ratio is checked to be in the range 0..0xFFFF.
> 
> I guess you are meaning `length' rather than `value'.
> 
> It is certainly possible to implement that. 
> 
> But it will kill any connection which has NN options with a valid value but
> unorthodox length. If that is what people want, then the following happens:
> 
>  * NN Change L arrives with valid value, but results in an empty
>    Confirm R since the length is unorthodox with regard to RFC 4340;
>  * receiving empty Confirm R resets the connection;
>  * with mandatory options the Reset will happen even earlier;
>  * a NN Confirm R with valid value (i.e. corresponding to the original
>    value of the Change L) resets the connection as per RFC 4340, 6.6.8.
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
