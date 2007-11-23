From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 23 Nov 2007 10:58:57 +0000
Subject: Re: [RFC]: Withdrawal of passive-close patches
Message-Id: <20071123105857.GA12151@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071122153843.GA13762@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071122153843.GA13762@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The situation is clearer now: the passive-close patches are redundant, but the 
problem still exists. A description is below; the three passive-close patches 
have been taken out of the test tree and the updated test tree has been uploaded to

	git://eden-feed.erg.abdn.ac.uk/dccp_exp 

I have debugged the problem of mysteriously vanishing short-lived connections further
and uploaded a test program to reproduce this behaviour on 

	http://www.erg.abdn.ac.uk/users/gerrit/dccp/short_connection_tests.tar.gz

(Any other program can also be used that writes a short string to a server and then
terminates. )

The bug is that a short-lived connection resulted in ECONNABORTED at the client,
while the complete transaction (initial handshake, data transfer, shutdown)
could be seen on the wire with tcpdump or wireshark.

The problem can best be seen using loopback (127.0.0.1), when starting the server
on a different host, a while loop can be used
      
        while ./client <serverHost> ; do sleep 1; done

and then this behaviour will occur at some random time.

The events leading up to this are as follows:

 1. ECONNABORTED is generated at the client before sys_connect() returns
 2. tracing this back leads to inet_stream_connect(), where ECONNABORTED appears
    under the jump label sock_error, triggered by the following condition:
	if (sk->sk_state = TCP_CLOSE)
		goto sock_error;
 3. since TCP_CLOSE = DCCP_CLOSED, the DCCP_CLOSED state was assumed before
    inet_stream_connect returned
 4. one candidate is dccp_rcv_close, which changes the socket state within
    the backlog handler (so that userspace has no chance):

	static void dccp_rcv_close(struct sock *sk, struct sk_buff *skb)
	{
		// ...
		dccp_set_state(sk, DCCP_CLOSED);
		// ...
	}

However, simply taking out the dccp_set_state may not be the right thing to do, 
since then the socket remains in OPEN until the application closes it. The
SOCK_DONE flag may be exploited for such tests instead. And there is the
test for DCCP_CLOSED in dccp_close() -- without that, inet_destroy_sock() is
not called.
