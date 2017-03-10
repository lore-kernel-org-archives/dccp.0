From: David Miller <davem@davemloft.net>
Date: Fri, 10 Mar 2017 02:21:27 +0000
Subject: Re: [PATCH net] dccp/tcp: fix routing redirect race
Message-Id: <20170309.182127.1480610707735412471.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com>
In-Reply-To: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Jon Maxwell <jmaxwell37@gmail.com>
Date: Thu,  9 Mar 2017 12:15:21 +1100

> We have seen a few incidents lately where a dst_enty has been freed
> with a dangling TCP socket reference (sk->sk_dst_cache) pointing to that
> dst_entry. If the conditions/timings are right a crash then ensues when the
> freed dst_entry is referenced later on. A Common crashing back trace is:
 ...
> A closer look at the tcp_v4_err() handler revealed that do_redirect() will run
> regardless of whether user space has the socket locked. This can result in a 
> race condition where the same dst_entry cached in sk->sk_dst_entry can be 
> decremented twice for the same socket via: 
> 
> do_redirect()->__sk_dst_check()-> dst_release(). 
> 
> Which leads to the dst_entry being prematurely freed with another socket 
> pointing to it via sk->sk_dst_cache and a subsequent crash.
> 
> To fix this skip do_redirect() if usespace has the socket locked. Instead let 
> the redirect take place later when user space does not have the socket 
> locked.
> 
> The dccp code is very similar in this respect, so fixing it there too. 
> 
> As Eric Garver pointed out the following commit now invalidates routes. Which
> can set the dst->obsolete flag so that ipv4_dst_check() returns null and 
> triggers the dst_release().
> 
> Fixes: ceb3320610d6 ("ipv4: Kill routes during PMTU/redirect updates.")
> Cc: Eric Garver <egarver@redhat.com>
> Cc: Hannes Sowa <hsowa@redhat.com>
> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>

Please add the ipv6 side of this fix to this patch and repost.

Thank you.
