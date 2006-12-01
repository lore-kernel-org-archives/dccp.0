From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 01 Dec 2006 22:50:27 +0000
Subject: Re: [PATCH 5/8]: Add protection against invalid parameters
Message-Id: <5640c7e00612011450r2d8a2ecfme05a04496765799@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612011827.01580@strip-the-willow>
In-Reply-To: <200612011827.01580@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/2/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:

> [DCCP]: Add protection against invalid parameters to TFRC routines
>
> +       BUG_ON(p >  1000000);           /* p must not exceed 100%   */
> +       BUG_ON(p = 0);                 /* f(0) = 0, divide by zero */

I know I put the original BUG_ONs in but can we change this to a
DCCP_BUG or a WARN - just to prevent the possible issues depending on
bottom half context...

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
