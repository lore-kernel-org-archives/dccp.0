From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 13 May 2008 09:57:55 +0000
Subject: Re: [PATCH] DCCP: Fix to reset the connection with Reset Code 5	Option
Message-Id: <48296623.8040405@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <48294E9C.4060209@cn.fujitsu.com>
In-Reply-To: <48294E9C.4060209@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit Renker:

 Sorry for my stupid patch since I can get the test git tree.

 But, Is there any other way to get the git tree? I download a patch 
from following URL:
  
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/test-tree_2.6.25.diff.gz
 I used this patch to my linux-2.6.25, there is error happend. and it 
has compile error too.

 Is this patch is based on linux-2.6.25? If I want to send a patch, I 
must create my patch base on what version of kernel?

Thanks.

Gerrit Renker wrote:
> Quoting Wei Yongjun:
>   
>> If endpoint received invalid option, it must reset the connection with  
>> Reset Code 5 "Option Error", but current kernel send reset with Reset  
>> Code 4 "Packet Error".
>>
>>     
> Ack. However, this has already been fixed in the test tree where dccp_parse()
> both sets the Reset code and fills in the Data1..3 fields (not done by this patch).
>
> Within a span of two weeks this is the fourth DCCP patch which fixes bugs
> that already have fixes in the DCCP test tree. The same problems are fixed
> in two different locations.
>
> If you are doing DCCP work, please consider 
> http://www.linux-foundation.org/en/Net:DCCP_Testing#How_to_obtai
