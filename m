From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Sep 2006 10:51:57 +0000
Subject: Re: [PATCH 6/7] [DCCP]: Fix setting of packet size in CCID3
Message-Id: <200609221151.57230@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609221432.20022.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221432.20022.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  Set initial packet size to defaults as existing code doesn't work
|  as set_sockopt occurs after initialisation so dccps_packet_size
|  is of no use really.
Please see comments to patch 5/7; rather than setting a default,
ccid3hc{rx,tx}_s should be derived from incoming/outgoing effective
packet sizes.

|  +	case DCCP_SOCKOPT_TX_PACKET_SIZE:
|  +		if (dmsk->dccpms_tx_ccid != DCCPC_CCID3)
|  +			err = -EINVAL;
This is unfortunate: it is in the generic dccp code but
works only for CCID 3. Same for DCCP_SOCKOPT_RX_PACKET_SIZE.


--Gerrit
