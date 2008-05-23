From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 23 May 2008 07:39:16 +0000
Subject: Re: QUESTION: About the RFCs of DCCP
Message-Id: <483674A4.10608@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <48364E35.80606@cn.fujitsu.com>
In-Reply-To: <48364E35.80606@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> | I am plan to make an Conformance Test Suite for DCCP which is under
> | packet level. It's aim to test the packet format, options, feature,
> | sequence numbers, event processing etc. base on the rfc4340. Maybe also
> | rfc4341, rfc4342.
> | 
> Maybe this is of help, Andrea Bittau did something similar earlier, at
> http://tapir.cs.ucl.ac.uk/pccd/
>   
I have saw this, but it is has so little test case. And looks like it 
has no test log detail.
> Just out of curiosity - are you using an existing system such as PCS 
> (http://pcs.sourceforge.net/) or KAME/TAHI?
>
>   
I am used TAHI's v6eval, and added DCCP support. So The test log  looks 
very good.^_^

Now it is under development. After it completed, I'll publish the test 
tools and test result.



