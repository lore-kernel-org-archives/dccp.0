From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 28 Nov 2007 14:10:56 +0000
Subject: Re: [PATCH 3/4]: Integrate state transitions for passive-close
Message-Id: <20071128141054.GC25255@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11962389113453-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11962389113453-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Nov 28, 2007 at 08:35:10AM +0000, Gerrit Renker escreveu:
> [DCCP]: Integrate state transitions for passive-close
> 
> This adds the necessary state transitions for the two forms of passive-close
> 
>  * PASSIVE_CLOSE    - which is entered when a host   receives a Close;
>  * PASSIVE_CLOSEREQ - which is entered when a client receives a CloseReq.
> 
> Here is a detailed account of what the patch does in each state.
>   
> 1) Receiving CloseReq
> ----------------------
>   The pseudo-code in 8.5 says:
> 
>      Step 13: Process CloseReq
>           If P.type = CloseReq and S.state < CLOSEREQ,
>               Generate Close
>               S.state := CLOSING
>               Set CLOSING timer.
> 
>   This means we need to address what to do in CLOSED, LISTEN, REQUEST, RESPOND, PARTOPEN, and OPEN.
> 
>    * CLOSED:         silently ignore - it may be a late or duplicate CloseReq;
>    * LISTEN/RESPOND: will not appear, since Step 7 is performed first (we know we are the client);
>    * REQUEST:        perform Step 13 directly (no need to enqueue packet);
>    * OPEN/PARTOPEN:  enter PASSIVE_CLOSEREQ so that the application has a chance to process unread data.
> 
>   When already in PASSIVE_CLOSEREQ, no second CloseReq is enqueued. In any other state, the CloseReq is ignored.
>   I think that this offers some robustness against rare and pathological cases: e.g. a simultaneous close where
>   the client sends a Close and the server a CloseReq. The client will then be retransmitting its Close until it
>   gets the Reset, so ignoring the CloseReq while in state CLOSING is sane.
>   
> 2) Receiving Close
> -------------------
>   The code below from 8.5 is unconditional.
> 
>      Step 14: Process Close
>           If P.type = Close,
>               Generate Reset(Closed)
>               Tear down connection
>               Drop packet and return
> 
>   Thus we need to consider all states:
>    * CLOSED:           silently ignore, since this can happen when a retransmitted or late Close arrives;
>    * LISTEN:           dccp_rcv_state_process() will generate a Reset ("No Connection");
>    * REQUEST:          perform Step 14 directly (no need to enqueue packet);
>    * RESPOND:          dccp_check_req() will generate a Reset ("Packet Error") -- left it at that;
>    * OPEN/PARTOPEN:    enter PASSIVE_CLOSE so that application has a chance to process unread data;
>    * CLOSEREQ:         server performed active-close -- perform Step 14;
>    * CLOSING:          simultaneous-close: use a tie-breaker to avoid message ping-pong (see comment);
>    * PASSIVE_CLOSEREQ: ignore - the peer has a bug (sending first a CloseReq and now a Close);
>    * TIMEWAIT:         packet is ignored.
> 
>    Note that the condition of receiving a packet in state CLOSED here is different from the condition "there
>    is no socket for such a connection": the socket still exists, but its state indicates it is unusable.
> 
>    Last, dccp_finish_passive_close sets either DCCP_CLOSED or DCCP_CLOSING = TCP_CLOSING, so that 
>    sk_stream_wait_close() will wait for the final Reset (which will trigger CLOSING => CLOSED).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied
