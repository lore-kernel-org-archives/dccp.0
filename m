From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 02 Jul 2008 09:42:13 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080702094213.GC4479@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[limited the lists to dccp@vger since this is DCCP-specific and not a patch]

> Ok, so now we know how to store information about parameters in kernel
> structures. What remains to be discussed is how to pass that information
> to userspace.
>
To me the less spectacular way of "just document it" still seems the best
solution. The other suggestion (below) is to divide this requirement
and, if really needed, use an API library which provides such mechanisms.

>> Further, the protection is not a strong one: nothing stops the user from 
>> first declaring parameters X/Y and then supply something completely different.
> We could make it strong that is enforce that when a parameter was not 
> declared it cannot be used.
>
Still not convinced that we need to do it in the kernel, see below.


>> | To make things clear: we both agree that the application should be able 
>> |to get information if the parameters it wants to use are supported by 
>> | the kernel it's running on, right?
>> That is the central point. What we agree on is that that the policy 
>> should validate the parameters that the user supplies via cmsg. 
> Yes. But it's only part of the problem. We should also allow applications 
> to detect which parameters are ok before calling sendmsg().
>
Please see below.

>> We don't need the bitmask approach,
>> and with your suggested solution we have a mapping (.params field) between 
>> parameters
>> and policy IDs.
>> Which is sufficient to find out which parameters are acceptable for a 
>> policy.
> The .param field idea only shows how we store that information in kernel. 
> It doesn't show how the user can retrieve that information.
>
If you want this, we could go back to the bitmask approach. That was the
original idea behind it: by encoding the parameters in a sub-bitfied of
the qpolicy ID, the set of associated parameters would be self-documenting.

But as per earlier message I don't like this idea, even if it is mine.
Protecting the user and smart mechanisms can just as well (very likely much
better) be implemented one layer above - in a "congestion API" library for
instance.
