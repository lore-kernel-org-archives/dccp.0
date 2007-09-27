From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Date: Thu, 27 Sep 2007 16:30:03 +0000
Subject: Re: DCCP support in VLC
Message-Id: <200709271930.03854.rdenis@simphalempin.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

	Hello (again)!

Le Thursday 27 September 2007 11:36:27, vous avez écrit :
> |  I am having a few API problems now:
> |
> |  First, TCP-like non-blocking connect() error handling does not seem to
> | work properly (2.6.22). I don't know if this is an intended difference
> | from TCP. VLC follows a pretty typical non-blocking connect flow:
> |
> |  socket()
> |  fcntl(F_SETFL, O_NONBLOCK)
> |  connect() = -1 (errno = EINPROGRESS)
> |  poll(POLLOUT) = 1
> |  getsockopt(SOL_SOCKET, SO_ERROR) = 0 (val = ECONNREFUSED)
> |
> |  Alas with DCCP, getsockopt returns 0 instead of ECONNREFUSED, even
> | though tcpdump reports a reset packet on the wire. And then VLC thinks
> | the connection succeeded, and well, tries to read from the socket...
>
> Two questions - first, are you ok with me copying the above to dccp@vger?
> My hands are full with other work, yet I believe the API should match that
> of TCP as close as possible (and that has been a main emphasis of the
> work).

No problem. Here goes.

> Second question: did you try the patches I sent you? I believed that I had
> solved the problem, see the hunk below from src/network/udp.c. This works
> fine (I watched a full DVD over DCCPv6 with CCID2 yesterday and have been
> using this for weeks). It is another technique for non-blocking connect.
>
> If you can teach me why your approach leads to the above error and why the
> approach below works, we would be one step further - so do let me know.
>
> @@ -667,6 +669,30 @@ int __net_ConnectDgram( vlc_object_t *p_
>  #endif
>              b_unreach = VLC_TRUE;
>          else
> +        if ( errno = EINPROGRESS )
> +        {
> +            fd_set wfds;
> +            int so_error = -1;
> +            socklen_t optlen = sizeof (int);
> +
> +            FD_ZERO(&wfds);
> +            FD_SET(fd, &wfds);
> +            msg_Warn( p_this, "IN PROGRESS %s port %d : %s", psz_host,
> i_port, +                      strerror( errno ) );
> +            if (select(fd + 1, NULL, &wfds, NULL, NULL) < 0)
> +            {
> +                msg_Err( p_this, "cannot connect to %s port %d : %s",
> psz_host, i_port, +                         strerror( errno ) );
> +                return -1;
> +            }
> +            i_handle = fd;
> +            if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &so_error, &optlen) <
> 0) +                msg_Err( p_this, "cannot get SO_ERROR: %s", strerror(
> errno ) ); +            else
> +                msg_Dbg( p_this, "connect completed %fully", so_error?
> "UNSUCCESS" : "success"); +            break;
> +        }
> +        else
>          {
>              msg_Warn( p_this, "%s port %d : %s", psz_host, i_port,
>                        strerror( errno ) );

The issue with the above patch was, it does actually check the so_error (apart 
from printing a debug message), so the caller does not know whether connect() 
succeeded or failed. (Another problem is that it broke the lame way VLC does 
thread cancellation but that's my problem, not yours).
But your other kernel patch solved that now :-)

So so, now I have yet another API problem :-$ When the peer shutdowns/closes 
the connection, recv() returns 0 (as with TCP). When the peer sends a 
zero-byte payload datagram, recv() also seems to return 0 (as with UDP).
How do I differentiate? With TCP and UDP, this is unambiguous because UDP has 
no such thing as shutdown, and TCP has no framing, so no empty payloads at 
application-layer. Is the idea to assume that 0 means shutdown and the peer 
is anyway brain-dead if it sends empty datagrams?

N.B.: please cc me on replies.

-- 
Rémi Denis-Courmont
http://www.remlab.net/
