From: David Miller <davem@davemloft.net>
Date: Wed, 26 Sep 2007 05:42:04 +0000
Subject: Re: [PATCH 5/6] [DCCP]: Fix Reset/Sync-Flood Bug
Message-Id: <20070925.224204.01034261.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070922211021.GJ4887@ghostprotocols.net>
In-Reply-To: <20070922211021.GJ4887@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 18:10:21 -0300

> This updates sequence number checking with regard to RFC 4340, 7.5.4.
> Missing in the code was an exception for sequence-invalid Reset packets,
> which get a Sync acknowledging GSR, instead of (as usual) P.seqno.
> 
> This can lead to an oscillating ping-pong flood of Reset packets.
> 
> In fact, it has been observed on the wire as follows:
> 
>  1. client establishes connection to server;
>  2. before server can write to client, client crashes without notifying
>     the server (NB: now no longer possible due to ABORT function);
>  3. server sends DCCP-Data packet (has no ackno);
>  4. client generates Reset "No Connection", seqno=0, increments seqno;
>  5. server replies with Sync, using ackno = P.seqno;
>  6. client generates Reset "No Connection" with seqno = ackno + 1;
>  7. goto (5).
> 
> The difference is that now in (5) the server uses GSR.  This causes the
> Reset sent by the client in (6) to become sequence-valid, so that in (7)
> the vicious circle is broken; the Reset is then enqueued and causes the
> socket to enter TIMEWAIT state.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied, thanks.
