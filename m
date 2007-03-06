From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 Mar 2007 09:20:02 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <200703060920.02279@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Andre,

thank you for continued testing. I spent a long while yesterday evening isolating
possible causes. Here are further pointers

1. Can you please tell us which kernel you are using? If it is a very recent
   one, can you please check whether you get the following message in your
   syslog:
                "[...] listen_overflow!"

   If yes (dccp_debug should be turned on), then very likely setting listen(fd, 1)
   instead of listen(fd,0) may remove any strange effects. 
   The reason is a recent change in sk_accept_queue_is_full which causes a different
   treatment of zero-sized listen-accept queues.

2. With the most recent davem-2.6 kernel I was not able to reproduce this bug. It 
   should, after some more thought, really make no difference whether you are using
   loopback (127.0.0.1) or not.

3. I analyzed the reverted patch you identified. There is indeed a loophole (which
   has not become visible so far), hence I will send 
   (a) an update of this patch 
   (b) a second patch to do with timer initialisation of child sockets.
   In particular (a) may help. 

4. It may be worth trying a different application, e.g. 

       http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/ttcp_dccp.tar.gz     
   in order to find out which combination of system calls triggers the bug condition.
   I managed to get the paraslash application built, but could not figure out how to
   populate the user lists and required configuration files. 
   I don't understand your code fully yet, but with the more recent stack trace I
   was wondering whether this has to do with setting the listen socket non-blocking
   (mark_fd_nonblock), which is done both in sender and receiver.


Again, many thanks for providing detailed information
Gerrit

Quoting Andre Noll:
| The bug remains, but the backtrace is slightly different,
|  see below.
|  
|  > > The BUG is caused via the following chain: 
|  > > 
|  > > 1. dccp_write_xmit(sk, 0) (due to !block)
|  > > 1. dccp_sendmsg
|  > > 2. ccid2_hc_tx_send_packet -> with hctx->ccid2hctx_pipe >= hctx->ccid2hctx_cwnd
|  > >    (see above, pipe=cwnd=1) => returns 1
|  > > 3. in dccp_write_xmit(sk, 0):
|  > >    if (!block) {                 /* this is true here */
|  > > 		sk_reset_timer(sk, &dp->dccps_xmit_timer,
|  > >    				msecs_to_jiffies(err)+jiffies)
|  > >    => BUG()
|  > > |   <7>dccp_set_state: listen(c1580030) LISTEN     -> CLOSED
|  > > This may be a clue: this socket has not gone past listen state (i.e. not entered server)
|  > 
|  > Yes, the bug happens in para_server just at the moment the first client
|  > connects. No data is transfered to the client. I'll look into the kernel
|  > dccp code a bit this evening as well.
|  
|  Found nothing suspicious. Apparently, dccp_connect() in
|  net/cddp/output.c is never called as this is the only place where
|  dp->dccps_xmit_timer.function is set, and the BUG in kernel/timer.c
|  indicates that this function pointer is NULL.
