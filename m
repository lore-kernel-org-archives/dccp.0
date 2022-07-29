From: Jakub Kicinski <kuba@kernel.org>
Date: Fri, 29 Jul 2022 15:44:48 +0000
Subject: Re: [PATCH] dccp: put dccp_qpolicy_full() and dccp_qpolicy_push() in the same lock
Message-Id: <20220729084448.5a4492cc@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20220727080609.26532-1-hbh25y@gmail.com>
In-Reply-To: <20220727080609.26532-1-hbh25y@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, 29 Jul 2022 18:34:39 +0800 Hangyu Hua wrote:
> >> thread1--->lock
> >> thread1--->dccp_qpolicy_full: queue is full. drop a skb  
> > 
> > This linie should say "not full"?  
> 
> dccp_qpolicy_full only call dccp_qpolicy_drop when queue is full. You 
> can check out qpolicy_prio_full. qpolicy_prio_full will drop a skb to 
> make suer there is enough space for the next data. So I think it should 
> be "full" here.

Oh, I see what you're saying. That's unnecessarily complicated, 
I reckon. The "simple" policy suffers from the same problem and 
is easier to understand. Anyway, you already sent v2 and it doesn't
matter enough to warrant v3, so fine.
