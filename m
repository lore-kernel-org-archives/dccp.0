From: David Miller <davem@davemloft.net>
Date: Tue, 14 Mar 2017 04:56:19 +0000
Subject: Re: [PATCH net, v2] dccp/tcp: fix routing redirect race
Message-Id: <20170313.215619.510745577558137603.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1489124433-32092-1-git-send-email-jmaxwell37@gmail.com>
In-Reply-To: <1489124433-32092-1-git-send-email-jmaxwell37@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Jon Maxwell <jmaxwell37@gmail.com>
Date: Fri, 10 Mar 2017 16:40:33 +1100

> As Eric Dumazet pointed out this also needs to be fixed in IPv6.
> v2: Contains the IPv6 tcp/Ipv6 dccp patches as well.
> 
> We have seen a few incidents lately where a dst_enty has been freed
> with a dangling TCP socket reference (sk->sk_dst_cache) pointing to that
> dst_entry. If the conditions/timings are right a crash then ensues when the
> freed dst_entry is referenced later on. A Common crashing back trace is:
 ...
> Of course it may happen with other NIC drivers as well.
> 
> It's found the freed dst_entry here:
 ...
> But there are other backtraces attributed to the same freed dst_entry in
> netfilter code as well.
> 
> All the vmcores showed 2 significant clues:
> 
> - Remote hosts behind the default gateway had always been redirected to a
> different gateway. A rtable/dst_entry will be added for that host. Making
> more dst_entrys with lower reference counts. Making this more probable.
> 
> - All vmcores showed a postitive LockDroppedIcmps value, e.g:
> 
> LockDroppedIcmps                  267
> 
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
> The dccp/IPv6 code is very similar in this respect, so fixing it there too.
> 
> As Eric Garver pointed out the following commit now invalidates routes. Which
> can set the dst->obsolete flag so that ipv4_dst_check() returns null and
> triggers the dst_release().
> 
> Fixes: ceb3320610d6 ("ipv4: Kill routes during PMTU/redirect updates.")
> Cc: Eric Garver <egarver@redhat.com>
> Cc: Hannes Sowa <hsowa@redhat.com>
> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>

Applied and queued up for -stable, thank you.
