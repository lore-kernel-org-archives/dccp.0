From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 19 Jun 2008 07:18:47 +0000
Subject: Re: QUESTION : Feature length about the non-negotiable feature
Message-Id: <485A0857.1050508@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <48579530.4010807@cn.fujitsu.com>
In-Reply-To: <48579530.4010807@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
>>> Thus, although the RFC says otherwise, I think that using the smallest
>>> option size for a given value is the right thing to do.
>>>
>>>   
>>>       
>> Yes, you can save some space for store more data, but this break the  
>> compatibility. If the other system implement follow the RFC, since those  
>> feature will be treat as invalid value. Also if it is set as mandatory  
>> option, assoc will be reset. endpoint with different implement can not  
>> talk to each other. That is the problem.
>>
>>     
> After your email yesterday I checked the RFC and found it indeed uses
> fixed lengths. I have therefore updated the code so that the NN options
> have the described fixed lengths (Ack Ratio = 2, Sequence Window = 6).
>
> This has been tested, I will post the changelog for the test tree
> shortly and upload the amended tree. I would be grateful if you could
> give this a spin with your test cases.
>
>   

With the patch, it is OK for send non-negotiable features. But not valid 
for check invalid value when recv.


