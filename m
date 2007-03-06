From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 Mar 2007 16:16:16 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <200703061616.16176@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Further insights after several kernel recompilations.
  
|  I checked 2.6.19.x (which works), 2.6.20, 2.6.20.1 and 2.6.21-rc1
|  (which all have the bug). 2.6.21-rc2 wouldn't compile on my system
|  due to some apic isssue.
Since I couldn't reproduce the bug on the current kernel (2.6.21-rc2), I
reverted to 2.6.21-rc1 and tried the paraslash application as described.
I got a "main: dccp connect error" when connecting to the paraserver (which
was listening on port 5001, as `ss' reported). With wireshark, I could see
that the handshake and the close request were both handled correctly, so it
seems that the connect error was rather down to a user error.
After recompiling to the most recent 2.6.20-rc2, same error. I also changed
configuration to PREEMPT but need to leave further testing for now.

|  
|  >  If it is a very recent
|  >    one, can you please check whether you get the following message in your
|  >    syslog:
|  >                 "[...] listen_overflow!"
|  > 
|  >    If yes (dccp_debug should be turned on), then very likely setting listen(fd, 1)
|  >    instead of listen(fd,0) may remove any strange effects. 
|  >    The reason is a recent change in sk_accept_queue_is_full which causes a different
|  >    treatment of zero-sized listen-accept queues.
|  
|  Will test this evening and report tomorrow.
This is indeed a(nother) bug - zero-sized listen queues currently do not work. Patch
submitted to netdev.

|  
|  > 2. With the most recent davem-2.6 kernel I was not able to reproduce this bug. It 
|  >    should, after some more thought, really make no difference whether you are using
|  >    loopback (127.0.0.1) or not.
|  
|  I can try this kernel as well. I'm currently downloading
|  
|  	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
|  	
|  Hope, that's the right one.
Yes that should work. There is also a net-2.6.22.git but I think it is only there for the
more recent changes which not yet have made it into 2.6.

|  >    (a) an update of this patch 
|  >    (b) a second patch to do with timer initialisation of child sockets.
|  >    In particular (a) may help. 
|  
|  OK. Are these patches against the current linus-tree?
They should work on any recent 2.6.19/20 tree (maybe with some offset).


  
|  >    I managed to get the paraslash application built, but could not figure out how to
|  >    populate the user lists and required configuration files. 
|  
|  That's explained in the INSTALL file. But you don't need any
Thanks - it was not spite not to rtfm, rather since busy with a lot of other stuff at the moment.

|  >    I don't understand your code fully yet, but with the more recent stack trace I
|  >    was wondering whether this has to do with setting the listen socket non-blocking
|  >    (mark_fd_nonblock), which is done both in sender and receiver.
|  
|  IMHO it's considered good practice to set all fds which are used for
|  select() to non-blocking mode.  AFAIR the reason is the situation
|  where a network packet arrives but is discarded because of a checksum
|  error. In this case it might happen that select() indicates readability
|  of an fd, but a subsequent read() blocks nevertheless. Maybe it's
|  unneccesssary to set an fd to non-blocking mode if it is only used
|  for writing. But it won't hurt either, so..
Oh sorry - it was not my intention to talk about programming style. The code is fine and
you are right with what you are saying. It is just that I wanted to pin down the exact
cause of the bug as in `it happens on non-blocking socket when X and Y and Z hold' &)
