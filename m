From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 09 Apr 2008 06:49:28 +0000
Subject: Re: [RFC][PATCH 10/12][NETNS][DCCPV6]: Move the dccp_v6_ctl_sk on
Message-Id: <47FC66F8.8060705@openvz.org>
List-Id: <dccp.vger.kernel.org>
References: <47FBAB09.9000305@openvz.org>
In-Reply-To: <47FBAB09.9000305@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> -/* Socket used for sending RSTs and ACKs */
>> -static struct sock *dccp_v6_ctl_sk;
>> +/* dccp_v6_ctl_sk is used for sending RSTs and ACKs */
> 
> Wrong comment?

Well, I tried to keep the comment, but it seems like the new
version is not much better than the old one :( I'll try to 
improve that...

Thanks,
Pavel
