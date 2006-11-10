From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 10 Nov 2006 14:07:42 +0000
Subject: Re: RFC about 07a_putative_nested_lock_in_rcv.diff
Message-Id: <200611101407.42211@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611100550w7343a3d5l45cc0e4bc4703d0d@mail.gmail.com>
In-Reply-To: <39e6f6c70611100550w7343a3d5l45cc0e4bc4703d0d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo Carvalho de Melo wrote:
|  Gerrit,
|  
|          I'm going over the_whole_lot patch queue from you, many thanks
|  for doing this work! About 07a_putative_nested_lock_in_rcv.diff, I
|  haven't studied the bh_lock_sock_nested, lockdep stuff, but can't we
|  just use bh_lock_sock_nested in sk_receive_skb?
I am not sure about that one - I don't know all the functions calling
sk_receive_skb (cscope says ppoe.c / dn_nsp_in.c use this too). 

In the TCP/DCCP case it is clear (due to the cloning while one is held under
a lock), but for other contexts it might be different and cause subtle problems.

Gerrit
