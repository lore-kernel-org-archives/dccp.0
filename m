From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 13:25:07 +0000
Subject: Re: [PATCH 1/5] CCID 4: Adds Kconfig, Makefile, and new CCID to include/linux/dccp.h
Message-Id: <5bc4c4570709200625g2a68ab74qf555bcf63434d089@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920112021.GB1288@kikai.katei.fi>
In-Reply-To: <20070920112021.GB1288@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Yes, this is one of my fixes.

Leandro.

2007/9/20, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> |  +# The TFRC-SP Library: currently only has CCID 4 as customer
> |  +config IP_DCCP_TFRC_SP_LIB
> |  +depends on IP_DCCP_CCID4
> |  +def_tristate IP_DCCP_CCID4
> |  +
> |  +config IP_DCCP_TFRC_SP_DEBUG
> |  +bool
> |  +default y if IP_DCCP_CCID4_DEBUG
> |  +
> You can delete these lines - they are already enabled through CCID3 configuration option,
> or integrate (OR) with the CCID3 dependencies. Since there are dependencies to CCID3,
> it may be useful to replace the above by adding
>         select IP_DCCP_CCID3
> to the menu of IP_DCCP_CCID4
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
