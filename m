From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 28 Nov 2007 14:05:39 +0000
Subject: Re: [PATCH 2/4]: Dedicated auxiliary states to support
Message-Id: <20071128140539.GB25255@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11962389112696-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11962389112696-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Nov 28, 2007 at 08:35:09AM +0000, Gerrit Renker escreveu:
> [DCCP]: Dedicated auxiliary states to support passive-close
> 
> This adds two auxiliary states to deal with passive closes:
>   * PASSIVE_CLOSE    (reached from OPEN via reception of Close)    and
>   * PASSIVE_CLOSEREQ (reached from OPEN via reception of CloseReq)
> as internal intermediate states.	
> 
> These states are used to allow a receiver to process unread data before 
> acknowledging the received connection-termination-request (the Close/CloseReq).
> 
> Without such support, it will happen that passively-closed sockets enter CLOSED
> state while there is still unprocessed data in the queue; leading to unexpected
> and erratic API behaviour.
> 
> PASSIVE_CLOSE has been mapped into TCPF_CLOSE_WAIT, so that the code will seamlessly
> work with inet_accept() (which tests for this state).
> 
> The state names are thanks to Arnaldo, who suggested this naming scheme following
> an earlier revision of this patch.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Thanks, applied.

- Arnaldo
