From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 10:16:14 +0000
Subject: Re: [PATCH v2 - RESEND]: [CCID 3]: Track RX/TX packet size `s' using moving-average
Message-Id: <200611271016.15575@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611260959g57f43067p979cb308123f1c5b@mail.gmail.com>
In-Reply-To: <39e6f6c70611260959g57f43067p979cb308123f1c5b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  On 11/23/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  
|  > @@ -1022,6 +1047,9 @@ static void ccid3_hc_rx_packet_recv(stru
|  >         if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
|  >                 return;
|  >
|  > +       payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
|  
|  Should't we use (skb->len - dccp_hdr_len(skb)) to take into account
|  the different DCCP packet size header lengths? We can get payload in
|  other kinds of packets than just DATA, and even on DATAACK we should
|  not compute the sizeof(struct dccp_hdr_ack_bits) bytes into the
|  payload, no?
It would do the same. The above code is in the receiver side, dccph_doff*4 gives 
the header length including options. So for calculating the payload size it is not
necessary (although it is possible that payload_size = 0).
Or did you mean to swap the above statements?
