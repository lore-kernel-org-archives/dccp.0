From: Ian McDonald <imcdnzl@gmail.com>
Date: Wed, 15 Feb 2006 01:44:53 +0000
Subject: Re: [PATCH 1/1]: [CCID2]: Fix the use of the RTO timer
Message-Id: <cbec11ac0602141744p130054d1qd4618690dab28095@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060215013015.GA14878@tribal.sorbonet.org>
In-Reply-To: <20060215013015.GA14878@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/15/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> Drop sock reference count on timer expiration and reset.
>
> There was a hybrid use of standard timers and sk_timers.  This caused the
> reference count of the sock to be incorrect when resetting the RTO timer.  The
> sock reference count should now be correct, enabling its destruction, and
> allowing the DCCP module to be unloaded.
>
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
>
> ---
>
> diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c

This patch looks good in itself but there are further problems
unloading than this as it occurs also with the code base prior to
CCID2 merging....

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
