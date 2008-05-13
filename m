From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 May 2008 08:30:33 +0000
Subject: Re: [PATCH] DCCP: Fix to reset the connection with Reset Code 5
Message-Id: <20080513083033.GA11707@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <48294E9C.4060209@cn.fujitsu.com>
In-Reply-To: <48294E9C.4060209@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Wei Yongjun:
> If endpoint received invalid option, it must reset the connection with  
> Reset Code 5 "Option Error", but current kernel send reset with Reset  
> Code 4 "Packet Error".
>
Ack. However, this has already been fixed in the test tree where dccp_parse()
both sets the Reset code and fills in the Data1..3 fields (not done by this patch).

Within a span of two weeks this is the fourth DCCP patch which fixes bugs
that already have fixes in the DCCP test tree. The same problems are fixed
in two different locations.

If you are doing DCCP work, please consider 
http://www.linux-foundation.org/en/Net:DCCP_Testing#How_to_obtain
