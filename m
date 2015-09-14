From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 14 Sep 2015 11:55:06 +0000
Subject: Re: [PATCH 00/39] drop null test before destroy functions
Message-Id: <55F6B59A.4040104@users.sourceforge.net>
List-Id: <dccp.vger.kernel.org>
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Recent commits to kernel/git/torvalds/linux.git have made the following
> functions able to tolerate NULL arguments:
>
> kmem_cache_destroy (commit 3942d29918522)
> mempool_destroy (commit 4e3ca3e033d1)
> dma_pool_destroy (commit 44d7175da6ea)

How do you think about to extend an other SmPL script?

Related topic:
scripts/coccinelle/free: Delete NULL test before freeing functions
https://systeme.lip6.fr/pipermail/cocci/2015-May/001960.html
https://www.mail-archive.com/cocci@systeme.lip6.fr/msg01855.html


> If these changes are OK, I will address the remainder later.

Would anybody like to reuse my general SmPL approach for similar source
code clean-up?

Regards,
Markus
