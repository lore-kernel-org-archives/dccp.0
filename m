From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 28 Jun 2006 18:11:45 +0000
Subject: Re: [2.6 patch] net/dccp/: possible cleanups
Message-Id: <5640c7e00606281111y2b4e6d4at611d0195847377cc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060628165430.GM13915@stusta.de>
In-Reply-To: <20060628165430.GM13915@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Comments below:

On 6/29/06, Adrian Bunk <bunk@stusta.de> wrote:
> This patch contains the following possible cleanups:
> - sysctl.c: the Kconfig rules already disallow CONFIG_SYSCTL=n,
>             there's no need for an additional check
Agree

> - proper extern declarations for some variables in dccp.h
NAK - have sent another patch to shift these to feat.h. Arnaldo is
reviewing patches next week.

> - make the following needlessly global function static:
>   - ipv4.c: dccp_v4_checksum()
Agree

> - #if 0 the following unused functions:
>   - ackvec.c: dccp_ackvector_print()
>   - ackvec.c: dccp_ackvec_print()
>   - output.c: dccp_send_delayed_ack()

NAK on the first two. These are for debugging and DCCP still needs
improving so I think worthwhile having there in short term so we can
quickly call them if needed.

I will leave Arnaldo or Andrea to comment on last one...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
