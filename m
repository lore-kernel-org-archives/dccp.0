From: David Miller <davem@davemloft.net>
Date: Mon, 08 Dec 2008 09:16:39 +0000
Subject: Re: [PATCH 3/7] dccp: Integration of dynamic feature activation -
Message-Id: <20081208.011639.169128034.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1228581657-6724-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1228581657-6724-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:53 +0100

> This integrates feature-activation in the client:
> 
>  1. When dccp_parse_options() fails, the reset code is already set; request_sent\
>     _state_process() currently overrides this with `Packet Error', which is not
>     intended - changed to use the reset code supplied by dccp_parse_options().
> 
>  2. When feature negotiation fails, the socket should be marked as not usable,
>     so that the application is notified that an error occurred. This is achieved
>     by a new label 'unable_to_proceed': generating an error code of `Aborted',
>     setting the socket state to CLOSED, returning with ECOMM in sk_err.
> 
>  3. Avoids parsing the Ack twice in Respond state by not doing option processing
>     again in dccp_rcv_respond_partopen_state_process (as option processing has
>     already been done on the request_sock in dccp_check_req).
> 
> Since this addresses congestion-control initialisation, a corresponding
> FIXME has been removed.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
