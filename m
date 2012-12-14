From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Fri, 14 Dec 2012 13:34:19 +0000
Subject: Re: [PATCH] Fix: kmemleak in tcp_v4/6_syn_recv_sock and dccp_v4/6_request_recv_sock
Message-Id: <2134996.KkfensU2kV@cpaasch-mac>
List-Id: <dccp.vger.kernel.org>
References: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
In-Reply-To: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Friday 14 December 2012 05:26:05 Eric Dumazet wrote:
> Please correct the changelog to include the right commit, so that we can
> backport it to needed kernels later. This backport could be done by you
> or someone else, don't worry. First step is to get the first patch in
> current Linus tree, but with exact information in changelog.

Ok, will resubmit soon. Thanks for your help.


-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--
