From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 19 Jun 2007 14:08:50 +0000
Subject: Re: [PATCH 0/1]: Current BUGs
Message-Id: <200706191508.50667@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706191129.55105@strip-the-willow>
In-Reply-To: <200706191129.55105@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > 1. Write queue not empty
|  > ------------------------
|  > |   "KERNEL: assertion (skb_queue_empty(&sk->sk_write_queue))
|  > |  failed at net/core/stream.c (276)" in system log.
|  > I observed this also at some time - but with TCP.
|  
|  Humm, this means that when we call sk_stream_kill_queues, that now is
|  only called from inet_csk_destroy_sock (the other user is out of the
|  tree, in LLC patches I never got enough time to polish and submit)
|  that is called in three places:
|  
|  -> when we are killing childs that we're almost finishing the
|  connection setup (in inet_csk_listen_stop, called from dccp_close on
|  the master socket or in dccp_disconnect)
|  
|  -> in dccp_close for a client socket
|  
|  -> in dccp_done, that is when the socket is in TIME_WAIT, finally
|  having its last remnants released or in error conditions (write error
|  -> timeout)
|  
|  The BUG_TRAP basically means that we have packet(s) in the
|  sk_write_queue, that we should have purged before, ideas?
Sorry, at the moment I have no ideas but I am already monitoring my logs;
hope that others also have a look and report to the list.

At one time I thought that there are situations where it is okay to end
a DCCP connection which still had packets in the write queue, e.g. aborting
a connection.


|  > - the most recent occurrence was the Sync-flood fixes
|  > (which will be resubmitted soon).
|  
|  OK, try to make it applicable to what we have in net-2.6.23, i.e.
|  independent of the stuff we have now in the experimental tree.
Will do tomorrow, I think that this will need some work due to inter-dependencies.


|  Doh, I just applied my patch, will be in net-2.6.23 and I'll ask DaveM
|  to have it in 2.6.22 and the stable@kernel.org guys to get it into
|  stable as well.
Great - which in all likelihood means that the bug is quickly out of the way.
I have put the patch into the experimental tree but will take it out when 
resyncing with the davem-2.6.23 tree.
