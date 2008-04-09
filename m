From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 09 Apr 2008 09:12:16 +0000
Subject: Re: [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <47FC8870.2000400@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ups, I didn't cc the list previously, sorry.

Gerrit Renker pisze:
>>> | And where should struct dccp_qpolicy be defined? As it is in 
>>> qpolicy.h (can I | include it in include/linux/dccp.h?) or move it to 
>>> dccp.h?
>>> | -- include/linux/dccp.h is exported as headerfile to userspace and so 
>>> it would be better to include it in net/dccp/dccp.h as it is already done
>>> for net/dccp/ackvec.h
>>>
>> You mean these lines:
>> struct dccp_ackvec;
>> (...)
>> struct dccp_sock {
>> (...)
>>     struct dccp_ackvec      *dccps_hc_rx_ackvec;
>> (...)
>> ?
>> Here only structure declaration suffices because dccps_hc_rx_ackvec is a  
>> pointer. When it would become a static member then the compiler needs  
>> its size. And consequently it needs definition. So there are two options  
>> here:
>> a) keep it as a pointer (pro: clear separation of code between files,  
>> con: it is a pointer when in fact it doesn't need to be),
>> b) move stuctures definition to userspace exported include/linux/dccp.h  
>> and change field type to non pointer (pro: less hassle with memory  
>> allocation, con: qpolicy cod will be distributed among many files).
>>
> Arnaldo, do you have any suggestions ? 
> 
> It seems I have been giving the wrong advice.
> 
> But it is not really a problem. The above section is within the #ifdef
> __KERNEL__ so afaik is not visible to userland. So, yes, option (b) is
> the only alternative - maybe Arnaldo has a better suggestion.
> 
> struct ackvec can be declared as a pointer since it is used only by
> one of the currently 3 CCIDs. 
> 
> I can't see a clear way of using
> 
> 	dccp_sk(sk)->dccps_qpolicy = NULL
> 
> to mean "use default skb routines" (i.e. default policy), but this would
> allow to use a pointer and have a fallback.
> 
> 
> The University of Aberdeen is a charity registered in Scotland, No SC013683.
> 

