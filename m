From: David Miller <davem@davemloft.net>
Date: Mon, 08 Dec 2008 09:19:17 +0000
Subject: Re: [PATCH 7/7] dccp ccid-2: Phase out the use of boolean Ack
Message-Id: <20081208.011917.176472177.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1228581657-6724-8-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1228581657-6724-8-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:57 +0100

> This removes the use of the sysctl and the minisock variable for the Send Ack
> Vector feature, as it now is handled fully dynamically via feature negotiation
> (i.e. when CCID-2 is enabled, Ack Vectors are automatically enabled as per
>  RFC 4341, 4.).
> 
> Using a sysctl in parallel to this implementation would open the door to
> crashes, since much of the code relies on tests of the boolean minisock /
> sysctl variable. Thus, this patch replaces all tests of type
> 
> 	if (dccp_msk(sk)->dccpms_send_ack_vector)
> 		/* ... */
> with
> 	if (dp->dccps_hc_rx_ackvec != NULL)
> 		/* ... */
> 
> The dccps_hc_rx_ackvec is allocated by the dccp_hdlr_ackvec() when feature
> negotiation concluded that Ack Vectors are to be used on the half-connection.
> Otherwise, it is NULL (due to dccp_init_sock/dccp_create_openreq_child),
> so that the test is a valid one.
> 
> The activation handler for Ack Vectors is called as soon as the feature
> negotiation has concluded at the
>  * server when the Ack marking the transition RESPOND => OPEN arrives;
>  * client after it has sent its ACK, marking the transition REQUEST => PARTOPEN.
> 
> Adding the sequence number of the Response packet to the Ack Vector has been
> removed, since
>  (a) connection establishment implies that the Response has been received;
>  (b) the CCIDs only look at packets received in the (PART)OPEN state, i.e.
>      this entry will always be ignored;
>  (c) it can not be used for anything useful - to detect loss for instance, only
>      packets received after the loss can serve as pseudo-dupacks.
> 
> There was a FIXME to change the error code when dccp_ackvec_add() fails.
> I removed this after finding out that:
>  * the check whether ackno < ISN is already made earlier,
>  * this Response is likely the 1st packet with an Ackno that the client gets,
>  * so when dccp_ackvec_add() fails, the reason is likely not a packet error.
> 
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Also applied, thanks Gerrit.
