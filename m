From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 04 Sep 2008 13:23:44 +0000
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change	feature-negotiation
Message-Id: <48BFE160.20901@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <20080823105647.GA15928@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080823105647.GA15928@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A ha, I understand your complaint, thank you!  This is an error in the spec 
and deserves an erratum.  The correct interpretation is to send an empty 
Confirm L.  The text of the spec should probably say "Change R and non-empty 
Confirm L options MUST NOT be sent ...".

Eddie


Gerrit Renker wrote:
> Thanks for the explanation Eddie.
>> I don't think this jump is "paradox."  DCCP's partner is asking to 
>> negotiate a non-negotiable feature, so IT doesn't think the feature is 
>> non-negotiable! (Otherwise it wouldn't have started the negotiation.)  We 
>> send an empty Confirm to slap it and tell it to get with the program.  
>> The pseudocode in section 6.6.2 indicates that an endpoint receiving an 
>> empty Confirm simply gives up the negotiation without changing the value. 
>>  This is what we want to happen.
>>
> Hm, the paradox (and that is what I was trying to raise) is in 6.3.2:
>    "Change R and Confirm L options MUST NOT be sent for non-negotiable
>     features; see Section 6.6.8."
> While the above steps seem right to me, still there is the problem that
> this step requires sending a message which is defined as invalid, i.e.
> we can not do the right thing because 6.3.2 says we must not.
> 
> Will check the patch through again, with your comments we have some
> added confirmation.
> 
> Gerrit
> 
