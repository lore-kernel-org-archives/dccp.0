From: David Miller <davem@davemloft.net>
Date: Mon, 02 Mar 2009 11:08:10 +0000
Subject: Re: [PATCH 2/2] dccp: Do not let initial option overhead shrink
Message-Id: <20090302.030810.243875852.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 28 Feb 2009 09:38:29 +0100

> This fixes a problem caused by the overlap of the connection-setup and
> established-state phases of DCCP connections.
> 
> During connection setup, the client retransmits Confirm Feature-Negotiation
> options until a response from the server signals that it can move from the
> half-established PARTOPEN into the OPEN state, whereupon the connection is
> fully established on both ends (RFC 4340, 8.1.5).
> 
> However, since the client may already send data while it is in the PARTOPEN
> state, consequences arise for the Maximum Packet Size: the problem is that the
> initial option overhead is much higher than for the subsequent established
> phase, as it involves potentially many variable-length list-type options
> (server-priority options, RFC 4340, 6.4).
> 
> Applying the standard MPS is insufficient here: especially with larger
> payloads this can lead to annoying, counter-intuitive EMSGSIZE errors.
> 
> On the other hand, reducing the MPS available for the established phase by
> the added initial overhead is highly wasteful and inefficient.
> 
> The solution chosen therefore is a two-phase strategy:
> 
>    If the payload length of the DataAck in PARTOPEN is too large, an Ack is sent
>    to carry the options, and the feature-negotiation list is then flushed.
> 
>    This means that the server gets two Acks for one Response. If both Acks get
>    lost, it is probably better to restart the connection anyway and devising yet
>    another special-case does not seem worth the extra complexity.
> 
> The result is a higher utilisation of the available packet space for the data
> transmission phase (established state) of a connection.
> 
> The patch (over-)estimates the initial overhead to be 32*4 bytes -- commonly
> seen values were around 90 bytes for initial feature-negotiation options.
> 
> It uses sizeof(u32) to mean "aligned units of 4 bytes".
> For consistency, another use of 4-byte alignment is adapted.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied.
