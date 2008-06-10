From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 10 Jun 2008 08:36:14 +0000
Subject: Re: [PATCH] DCCP: Fix double free of skb which may cause kernel	panic
Message-Id: <484E3CFE.8020500@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <484E2DC3.1030407@cn.fujitsu.com>
In-Reply-To: <484E2DC3.1030407@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
>> Hi, Gerrit Renker
>>
>> Please ignore this mail, I will sent the patch again after the patch is  
>> witten correctly.
>>
>>     
> Yes indeed - there is a valid point here but it needs a bit more investigation.
>
> There are several paths for the control flow in dccp_v6_ctl_send_reset().
> I am further wondering, since dccp_v4_ctl_send_reset() is similar, if
> you can trigger the same condition in DCCPv4?
>
> Can not test this at the moment, probably not before today.
>   

This is happened when I write test case, and can be test again. The IPv4 
has no problem.
I test this used send REQUEST to endpoint with bad option, and the first 
time nothing happend, the second time kernel panic is happened.
But this problem it is not cause by kree_skb of 
dccp_v6_ctl_send_reset(), it has no problem since it not free skb while 
skb is sent correctly.

> Gerrit
>
>   
