From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 10:57:37 +0000
Subject: Re: [PATCH 1/25] CCID-4 Kconfig and Makefile
Message-Id: <20071108105737.GA15246@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312018.36512.leandroal@gmail.com>
In-Reply-To: <200710312018.36512.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| +config IP_DCCP_CCID4_DEBUG
| +         bool "CCID4 debugging messages"
| +         depends on IP_DCCP_CCID4
<snip>
| +# The TFRC Library: currently has CCID 3 and CCID 4 as customer
|  config IP_DCCP_TFRC_LIB
| -	depends on IP_DCCP_CCID3
| +	depends on IP_DCCP_CCID3 || IP_DCCP_CCID4
|  	def_tristate IP_DCCP_CCID3
|  
|  config IP_DCCP_TFRC_DEBUG
Suggestion: if CCID3 is not compiled as module, there will currently be
no TFRC debugging output for dccp_tfrc_lib when only CCID4 is enabled.
Something like

config IP_DCCP_TFRC_DEBUG
	bool
	default y if IP_DCCP_CCID3_DEBUG || IP_DCCP_CCID4_DEBUG 

would enable this.

On the other hand, the number of `debugs' keeps continually growing.
Maybe it is possible to just use tfrc_debug for everything that speaks
TFRC, otherwise we currently have
 * tfrc_debug   to enable debug messages in dccp_tfrc_lib
 * ccid3_debug            "                 dccp_ccid3
 * ccid4_debug            "                 dccp_ccid4
 * dccp_debug   to see the rest
