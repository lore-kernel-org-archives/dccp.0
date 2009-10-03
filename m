From: Schier Michael <michael.schier@uibk.ac.at>
Date: Sat, 03 Oct 2009 16:31:53 +0000
Subject: Re: sendbuffer-size controls (non)blocking behaviour? ccid3	throughput
Message-Id: <4AC77C79.1050000@uibk.ac.at>
List-Id: <dccp.vger.kernel.org>
References: <4AC3D430.7050409@uibk.ac.at>
In-Reply-To: <4AC3D430.7050409@uibk.ac.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


> | I'm doing some experiments over DCCP (Ubuntu kernel version 2.6.28-15) using CCID3. The following is
> | a list of things which confused me a bit. Maybe someone can give me an explanation...
> | All mentioned files in the following text can be found at http://138.232.66.193/public/.
> 
> You are using a generic ubuntu (jaunty) kernel?  As far as I know this is from the stable mainline branch.
> For all serious DCCP testing, please consider using the test tree
> 
>    http://www.linuxfoundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tree
> 
> The test tree is ahead of the mainline kernel and contains more up-to-date fixes. Even though the
> name is tagged 'experimental', the 'dccp' branch is checked to build cleanly and does not actually
> contain experimental patches; these are deferred to subtrees. It is quite possible that some of the
> described problems will disappear when using the test tree.
ok, I'm now using the kernel module from the experimental test tree -> I got rid of some problems!
> 
> 
> 
> | In all scenarios, I have a sender(A) and a receiver(C) application. Both half-connections use CCID3.
> | The sender transmits at full speed, the other half-connection isn't used. (shutdown(socket,SHUT_RD)
> | is called at the sender). Between A and C, I have another computer (B) and i applied tc qdisc add
> | dev ethx root tbf rate 40kbit burst 10kb limit 10kb
> | 
> | 1) I usually abort the sender with Ctrl+C. The sender sends a Close, the receiver immediately
> | answers with CloseReq. Then the sender agains sends a Close and repeats this after 6 seconds and
> | again after another 12 seconds. Then again the receiver sends a CloseReq and the sender returns
> | Close (and so on). And no, I haven't forgotten the receiver-side close(socket) call.
> |
> With regard to RFC 4340, the receiver doing the passive-open is the 'server'. When you kill the
> userspace application via CTRL-C, the sender performs an active close and enters the CLOSING state.
> Within this state, it will continue to retransmit Close packets until it receives a DCCP-Reset
> packet. 
> 
> The receiver would normally reply to a Close with a Reset. The receiver-side close(socket) call performs
>  an active close at the server side. Hence if I understand the situation correctly, what you are describing
> is a case of "simultaneous active close", i.e. sender and receiver perform an active close nearly
> simultaneously. There is no special provision for this condition in the RFC, but the implementation is
> equipped to handle it; described in 4.2 on
>    http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/
> The tie-breaker in this case is that the retransmitted Close packet triggers a DCCP-Reset with a 
> type of "No Connection", which then causes the state transition from CLOSING to TIMEWAIT.
As explained below, simultaneous active close calls should not happen.
> 
> However, in your wireshark capture there are also Resets of type "Aborted"i (all receiver port numbers
> less than 5008), which is the way the TCP ABORT function is implemented -- when the receiver (sender)
> is being disconnected. In capture with port number 5008, the Reset(Aborted) happens before the
> Reset(No Connection). It seems that in your application the receiver/sender calls close() before
> the sender is killed via CTRL-C, which would explain why the CloseReq appears before the Close.
I can exclude that. The simple server code is something like this:
while(1) {
  ...
  socket = accept(listenSocket, &remoteAddr, &remoteAddrLen);
  if(socket < 0)
    err(-1, "Error when accepting incoming connection!\n");
  while(1) {
    n = recv(socket, buffer, 1500, 0);
    if(n = 0) break;
    ...
  }
  close(socket);
}

> 
> In the connection using port number 5010 there are no CloseReqs (or any other type of packet back from
> 192.168.3.2), hence the the retransmit times out with a Reset eventually, i.e. it does not retransmit
> the Close ad infinitum if it does not get any response from the peer.
> 
> 
> | The receiver processed incoming connections in a while loop (one bind and listen call at the
> | beginning of the program, several accept and recv calls in the loop). From time to time, it happens
> | that I cannot establish a connection to the same port again and get the error "Too many users". The
> | receiver answer with a Reset packet, code "too busy". After several minutes, the port can be reused
> | again. after_application_end.* is a packet dump performed at B after doing some tests on various ports.
> 
> The EUSERS error is the translation of the 'too busy' DCCP_RESET_CODE_TOO_BUSY reset code. There are
> several possible causes:
> 
>  a) The size of the accept() queue set via the second parameter of listen(2).
>     This seems likely: in this case the DCCP-Request is handled by dccp_v{4,6}_conn_request, which
>     returns -1, causing dccp_rcv_state_process to return 1, which then causes dccp_v{4,6}_do_rcv
>     to send a reset with the previously-prepared reset code.
>     Could you test with different sizes of the 'backlog' argument to listen(2)?
> 
>  b) The request-accept queue which containing the half-finished connection requests. This is 
>     related to (a) since the queue size is also set via the 'backlog' argument to listen(). If
>     changing the 'backlog' in (a) does not change the setting, the problem might be in setting
>     nr_table_entries to a maximum of 16 in reqsk_queue_alloc(), which is the case when using a
>     value of 8 or greater for the 'backlog' argument.
>     The nr_table_entries is also influenced by tcp_max_syn_backlog, which however is much
>     larger (128 or 1024).
> 
>  c) Other causes would be rarer conditions such as running out of memory.
> 
Thank you for the detailed comments on that point! It seems as if the problem disappeared after
switching to the module from you test tree! I've run several tests and it didn't come back.
> 
> | 2) I send data packets with payload size 1000 bytes. When I choose a send buffer size <= 4976 bytes,
> | the send call is blocking as expected (setsockopt(socket, SOL_SOCKET, SO_SNDBUF, ...). By increasing
> | the send buffer by at least 1 byte, the socket is non-blocking. It returns EAGAIN until we are
> | allowed to send a new packet.
> 
> The EAGAIN results from the way CCID-3 currently dequeues packets, which is independent of setting the
> socket blocking/non-blocking. Unlike UDP, packets are not immediately dequeued after calling send/write,
> but rather depending on the current allowed sending rate.
> The default queue length in packets is /proc/sys/net/dccp/default/tx_qlen = 5. You can increase this 
> value or set it to 0 to disable the length check. This is the default mainline policy; in the test tree
> we have the qpolicy framework by Tomasz Grobelny, where the mainline dequeueing policy has been renamed
> into the 'simple' qpolicy.
ah, ok. I completely forgot about this parameter. 2) + 3) now makes complete sense to me.
> 
> | 3) Can I control the blocking/nonblocking behavior somehow? (e.g. using ioctl FIONBIO or O_NONBLOCK)
> Yes, as per (2). In CCID-2 the EAGAIN is very rarely possible, only if the network is severely congested
> or overloaded, so it may be better to start testing with this CCID-2 if you do want to use non-blocking.
> 
> 
> | 4) I also observed some strange behaviour here: I use tc qdisc add dev ethx root netem delay 50ms.
> | 50ms_noloss.jpg depicts the throughput. Why are there these periodic drops? There isn't any packet loss.
> | 
> It is difficult to say what exactly happened given just one figure. To verify that there is indeed no
> packet loss, it would be useful to have the dccp_probe data. This is much preferable to the socket option
> in (5) as it shows the internals directly. Even if it seems counter-intuitive, it is possible to cause
> packet loss with a Token Bucket Filter, for instance if the receiver queue size is not large enough.
> 
> Some notes for dccp_probes are on
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/
I've also checked this with dccp_probe, I forgot to mention this. The strange fluctuations
disappeared with the new module ;-)
> 
> | 5) I modified the scenario from point 4 and caused a single packet loss ~ at second 8,5 (50ms_singleloss.jpg).
> | By using getsockopt with DCCP_SOCKOPT_CCID_TX_INFO, I see that p (packet loss rate) gets a nonzero value, which
> | then decreases down to 0.01% but not further. Unfortunately, the connection can only reach a
> | 1/5 of the throughput before the packet drop. I know that the theoretic bandwidth utilization
> | depends on the bandwidth delay product, but is a rtt of 50ms such a dramatically high value??
> 
> This is governed by the formula for X_Bps in section 3.1 of RFC 5348; since the RTT is in the denominator, the
> allowed sending rate is inversely proportional to the RTT (i.e. 10-times higher RTT means 10 times lower X_Bps).
> 
I know, I was just puzzled by the fact that DCCP uses the complete available bandwidth until there
is packet loss. After that, without any further packet losses, DCCP will never be able to use more
than 20% of the available bandwidth because the loss event rate decreases so slowly. No need to
rever to RFCs again ;-), I believe you that this is the way it was specified, I just wondered why
there is no mechanism which drops "too old" loss intervals...

anyway, thank you very much for your help! Using the up-to-date module really made the difference.
