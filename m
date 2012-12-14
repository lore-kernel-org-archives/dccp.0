From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 14 Dec 2012 13:26:05 +0000
Subject: Re: [PATCH] Fix: kmemleak in tcp_v4/6_syn_recv_sock and dccp_v4/6_request_recv_sock
Message-Id: <1355491565.10504.7.camel@edumazet-glaptop>
List-Id: <dccp.vger.kernel.org>
References: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
In-Reply-To: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, 2012-12-14 at 08:59 +0100, Christoph Paasch wrote:
> Hi Eric,
> 
> On Thursday 13 December 2012 15:38:10 Eric Dumazet wrote:
> > Are you sure the above commit is the bug origin ?
> > 
> > It looks like bug was bring by transparent proxy in 2.6.37
> > 
> > commit 093d282321daeb19c107e5f1f16d7f68484f3ade
> > Author: Balazs Scheidler <bazsi@balabit.hu>
> > Date:   Thu Oct 21 13:06:43 2010 +0200
> 
> yes, you are right.
> 
> My patch would not easily apply on kernels < 3.0, as it depends on the 
> "put_and_exit"-goto.
> Should I send a separate patch? And to whom? (I don't find any guidelines 
> about how to submit patches to older stable kernels)
> 

Please correct the changelog to include the right commit, so that we can
backport it to needed kernels later. This backport could be done by you
or someone else, don't worry. First step is to get the first patch in
current Linus tree, but with exact information in changelog.

Thanks


