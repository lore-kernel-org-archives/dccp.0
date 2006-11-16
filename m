From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 16 Nov 2006 18:17:15 +0000
Subject: Re: CCID3: dead code in ccid3_hc_rx_packet_recv?
Message-Id: <200611161817.15764@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
In-Reply-To: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > I stumbled over two things and can make no sense of a bit of CCID 3 Receive code:
|  >
|  >         1) ccid3_hc_rx_sock maintains a real-timer RTT counter ccid3hcrx_rtt
|  >            which is an alias for a TFRC structure defined in <linux/tfrc.h>
|  
|  See comments below. Don't really understand what you are saying.
Sorry if my questions were really clear, part of this is probably due to my lack of understanding
what went on. I went through this again and I hope that this time it is clearer to understand.

  1) The above was expressed in too complicated a way. I meant to say "why does the receiver
     keep a real-time RTT counter"? I was referrind to the following element of code:

	struct ccid3_hc_rx_sock {
	struct tfrc_rx_info	ccid3hcrx_tfrc;
	/* 	... 	*/
	#define ccid3hcrx_rtt		ccid3hcrx_tfrc.tfrcrx_rtt

     And in <linux/tfrc.h>:

	struct tfrc_tx_info {
	/*	... 	*/
	__u32 tfrctx_rtt;
      
     I was puzzled why the receiver has to keep time while RFC 4342 speaks of `quarter RTT increases'
     For `pure' TFRC (:-) it is understandable why the receiver should track RTT, here I could not follow.


  2) With regard to the code I was referring to, the points are precisely:

	* the receiver appears not to look at the window counter
	* RTT is updated only on Ack/DataAck and  is never updated when the packet carries no timestamp, due to:
	  	case DCCP_PKT_ACK:
			if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
				return;
		case DCCP_PKT_DATAACK:
			if (opt_recv->dccpor_timestamp_echo = 0)
				break;
	* timestamps are permitted on any DCCP packet (RFC 4340, sec. 13); hence the code, if it is
          really used, could be pulled out and below the switch statement, to also use the timestamps
          of incoming Data packets

	* if I understand correctly, ccid3_hc_rx_packet_recv is in the receiving side of the
	  half-connection => receiver gets data and sends Acks
			  => but only receives (Data)Acks if it is also a sender or if it
                              has to ack e.g. AckVectors
	* the thing that puzzled me most is that ccid3_hc_tx_send_packet() uses the window counter as
          per RFC 4342 8.1 (visible in wireshark), but the receiver makes no use of it. 

 
|  >         2) ccid3_hc_rx_packet_recv (detailed below) updates this, but leaves the variable
|  >            `win_count = packet->dccphrx_ccval;'  entirely untouched after initialisation
|  >
|  This can be deleted. It was used but I have shifted the code into
|  ccid3_hc_rx_detect_loss. I forgot to delete this variable. I will
|  produce a patch to do this in next week if you don't.
Do you mean another function - I can not find any RTT-related code in ccid3_hc_rx_detect_loss.

|  >                 /*
|  >                    after updating r_sample with regard to t_elapsed ...
|  >                    => The code that now follows is identical with ccid3_hc_tx_packet_recv
|  >                        --is this a leftover ?
|  >                        --should it not rather update the sending structure (ccid3hctx_rtt)
|  
|  No they are half connections. Maybe I don't understand your question.
Again, sorry for not putting this clearly: my understanding is that currently the code works
unidirectional, i.e. a node is not both receiver and sender at the same time. This would be the most
sensible starting point; and in that case the above question is unnecessary. 
	
|  >                    => why not use win_count ??
|  
|  Can be deleted.
My intuition at the moment is that it should be the other way round (i.e. delete the timestamp-dependent code
and use window counter values as per RFC 4342): in any case I think this needs a revision. 
I have been doing some capturing tests to solve this question today, but ran out of time.
Another ToDo.

-- Gerrit
