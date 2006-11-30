From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Nov 2006 01:05:04 +0000
Subject: Re: [PATCH] [RFC]: Fine-grained sending rate resolution / division errors
Message-Id: <5640c7e00611291705g14b28bbei41fbc4f7afa8aa73@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611292052.01303@strip-the-willow>
In-Reply-To: <200611292052.01303@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/30/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Here is now the patch, I have had a hard time due to division of u64 by
> u32. I have also checked again - it is feasible to prune X_calc and
> X_recv back to u32. If you prefer that, I can change the patch.
>
Yes I remember having great difficulty with that too when I converted
the code from FreeBSD to Linux (and they had floating point as
well...) I never got further than what went into the code.

This all looks good in theory. Still trying to resolve earlier DCCP
CCID3 issues.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
