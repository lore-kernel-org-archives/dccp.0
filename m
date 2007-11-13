From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Tue, 13 Nov 2007 16:32:23 +0000
Subject: Re: [PATCH 1/25] CCID-4 Kconfig and Makefile
Message-Id: <5bc4c4570711130832j3a8f3d83k677da410b96f9d13@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312018.36512.leandroal@gmail.com>
In-Reply-To: <200710312018.36512.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/11/13, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> Quoting Leandro:
> | 2007/11/8, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> | > | +config IP_DCCP_CCID4_DEBUG
> | > | +         bool "CCID4 debugging messages"
> | > | +         depends on IP_DCCP_CCID4
> | > <snip>
> | > | +# The TFRC Library: currently has CCID 3 and CCID 4 as customer
> | > |  config IP_DCCP_TFRC_LIB
> | > | -     depends on IP_DCCP_CCID3
> | > | +     depends on IP_DCCP_CCID3 || IP_DCCP_CCID4
> | > |       def_tristate IP_DCCP_CCID3
> | > |
> | > |  config IP_DCCP_TFRC_DEBUG
> | > Suggestion: if CCID3 is not compiled as module, there will currently be
> | > no TFRC debugging output for dccp_tfrc_lib when only CCID4 is enabled.
> | > Something like
> | >
> | > config IP_DCCP_TFRC_DEBUG
> | >         bool
> | >         default y if IP_DCCP_CCID3_DEBUG || IP_DCCP_CCID4_DEBUG
> | >
> | > would enable this.
> | >
> | > On the other hand, the number of `debugs' keeps continually growing.
> | > Maybe it is possible to just use tfrc_debug for everything that speaks
> | > TFRC, otherwise we currently have
> | >  * tfrc_debug   to enable debug messages in dccp_tfrc_lib
> | >  * ccid3_debug            "                 dccp_ccid3
> | >  * ccid4_debug            "                 dccp_ccid4
> | >  * dccp_debug   to see the rest
> | > -
> |
> | Yes, it is better to have tfrc_debug for everything related to TFRC. I
> | will also fix the IP_DCCP_TFRC_DEBUG kconfig option like you
> | suggested.
> |
> Please do as you see fit, but don't worry too much at this stage - this
> can all be resolved later (i.e. further abstraction can be done later).
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Then I will let this as it is and after we can working on this. Ok?
