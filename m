From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Fri, 14 Dec 2012 07:59:38 +0000
Subject: Re: [PATCH] Fix: kmemleak in tcp_v4/6_syn_recv_sock and dccp_v4/6_request_recv_sock
Message-Id: <15583655.5x5gqCFMiY@cpaasch-mac>
List-Id: <dccp.vger.kernel.org>
References: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
In-Reply-To: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Eric,

On Thursday 13 December 2012 15:38:10 Eric Dumazet wrote:
> Are you sure the above commit is the bug origin ?
> 
> It looks like bug was bring by transparent proxy in 2.6.37
> 
> commit 093d282321daeb19c107e5f1f16d7f68484f3ade
> Author: Balazs Scheidler <bazsi@balabit.hu>
> Date:   Thu Oct 21 13:06:43 2010 +0200

yes, you are right.

My patch would not easily apply on kernels < 3.0, as it depends on the 
"put_and_exit"-goto.
Should I send a separate patch? And to whom? (I don't find any guidelines 
about how to submit patches to older stable kernels)


Thanks,
Christoph

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--
