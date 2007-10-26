From: David Miller <davem@davemloft.net>
Date: Fri, 26 Oct 2007 10:52:42 +0000
Subject: Re: [PATCHES 0/5]: DCCP bug fixes
Message-Id: <20071026.035242.47975775.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20071024131025.GC6371@ghostprotocols.net>
In-Reply-To: <20071024131025.GC6371@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Oct 2007 11:10:25 -0200

> Hi David,
> 
> 	Please consider pulling from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6
> 
> Gerrit Renker (5):
>       [DCCP]: Retrieve packet sequence number for error reporting
>       [DCCP]: One more exemption from full sequence number checks
>       [DCCP]: Convert Reset code into socket error number
>       [DCCP]: Unaligned pointer access
>       [CCID2/3]: Initialisation assignments of 0 are redundant

Pulled, thanks a lot!
