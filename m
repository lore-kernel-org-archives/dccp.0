From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Tue, 13 Nov 2007 16:14:17 +0000
Subject: Re: [PATCH 17/25] Share ccid3_tx_state_name function via tfrc_ccids
Message-Id: <5bc4c4570711130814g1964259en7ba7274dbbae0374@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312131.52573.leandroal@gmail.com>
In-Reply-To: <200710312131.52573.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/11/10, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> | [CCID-3/4] Share ccid3_tx_state_name function via tfrc_ccids
>
> There is a build problem in declaring the following routines as shared:
>
> #if defined(CONFIG_IP_DCCP_CCID3_DEBUG) || defined(CONFIG_IP_DCCP_CCID4_DEBUG)
> static const char *tfrc_tx_state_name(enum tfrc_hc_tx_states state)
> {
>         /* ... */
> }
> #endif
>
> #if defined(CONFIG_IP_DCCP_CCID3_DEBUG) || defined(CONFIG_IP_DCCP_CCID4_DEBUG)
> static const char *tfrc_rx_state_name(enum tfrc_hc_rx_states state)
> {
>         /* ... */
> #endif
>
> When enabling CCID3_DEBUG, but not CCID4_DEBUG, the following build warnings result:
>
> /usr/src/davem-2.6/net/dccp/ccids/lib/tfrc_ccids.h:163: warning: 'tfrc_tx_state_name' defined but not used
> /usr/src/davem-2.6/net/dccp/ccids/lib/tfrc_ccids.h:180: warning: 'tfrc_rx_state_name' defined but not used
>
> The reason is that the header file is #included in ccid4.c and this function is only called from
> within ccid4_pr_debug(). But when CCID4_DEBUG is disabled, this macro expands to an emptry string,
> so the compiler thinks that tfrc_{rx,tx}_state_name() is not used -- which is actually the case.
>
> So not very happy with the above solution. When getting serious about abstracting and sharing
> common code, the best think is probably to use a single debugging function, tfrc_pr_debug.
> This would be enabled when at least one of CCID3_DEBUG or CCID4_DEBUG is enabled, and one could
> add some magic that the module parameters influence the boolean variable tfrc_debug.
>
> The same could be done for the RTO timer - since the identical menu appears in both places.
>
> Maybe it is better for the moment to `un-share' the code.
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Yes Gerrit, this is one of the point that I will talk to you about. I
also agree with you, the best for the moment is to "un-share" this
function.

Leandro.
