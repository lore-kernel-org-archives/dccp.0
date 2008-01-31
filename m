From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 31 Jan 2008 20:33:40 +0000
Subject: Re: [PATCH 6/6] [TCP]: Reorganize struct tcp_sock to save 16 bytes
Message-Id: <20080131203340.GG11940@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1201804304-28777-7-git-send-email-acme@redhat.com>
In-Reply-To: <1201804304-28777-7-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Jan 31, 2008 at 06:17:20PM -0200, Arnaldo Carvalho de Melo escreveu:
> Em Thu, Jan 31, 2008 at 08:57:53PM +0100, Eric Dumazet escreveu:
> > Hum... retrans_out should sit close to packets_out (or lost_out/sacked_out 
> > ???), please.
> >
> > 'struct tcp_sock' is very large on 64 bits, so I would prefer to make sure 
> > most paths dont need to touch all 24 cache lines (or 25 cache lines).
> 
> That is perfectly fine, I'll replace my patch with another, that states
> this beyond doubt.

David, I just removed this patch from my net-2.6 tree, if you are ok
with the others, please pull.

- Arnaldo
