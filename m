From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 09 Nov 2006 11:23:21 +0000
Subject: Re: Sequence numbers in Response packets (Linux 2.6.17)
Message-Id: <200611091123.21706@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
In-Reply-To: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Quoting Ian McDonald:
|  On 9/27/06, Vladimir M <vladivm@mail.ru> wrote:
|  >
|  > Hi,
|  >
|  > While doing some tresting, I've noticed a funny behaviour of DCCP implementation in 2.6 kernel. From Ethereal capture seems that retransmitted response packets do not increment the sequence number. Is it a correct behaviour? If yes, then why is it done like this, since protocol's RFC instructs to increment on every outgoing packet.
|  >
|  > B.R.
|  > Vladimir.
|  >
|  > P.S. Don't know, it it has been already discussed on the list or not, or even patched. I have original DCCP version from 2.6.17 FC5, but havnt found anything related in archives of this list
|  
|  Vladimir,
|  
|  You are correct in saying this and it hasn't been fixed yet as of the
|  latest code. The reason for this is that we just clone the skb and
|  haven't updated the header. Feel free to get in and fix if you want!
|  
|  I have added this to the DCCP to do list -
|  http://linux-net.osdl.org/index.php/TODO#DCCP

Alas, there is some confusion here. 

The problem is not in cloning the skb, this works fine. 

The only identifiable problem that I can find in this regard sits in a different corner:
DCCP-Responses triggered both by receipt of a (retransmitted) DCCP-Request and, at a later
timer, through the dccp_response_timer(); details are also below.


1) Retransmission works!
------------------------
The only retransmittable packets are:
 *  Requests in client-REQUEST  state (sec. 8.1.1)
 *  Acks     in client-PARTOPEN state (sec. 8.1.5)
 *  CloseReq in server-CLOSEREQ state (sec. 8.3)
 *  Close    in   node-CLOSING  state (sec. 8.3)    

And these are taken care of by the dccp_retransmit_skb(), triggered via dccp_retransmit_timer().
That one in turn calls dccp_transmit_skb(), which has the lines

		dccp_inc_seqno(&dp->dccps_gss);
		/* ... */
		dccp_hdr_set_seq(dh, dp->dccps_gss);

This means that sent sequence numbers on retransmittable packets are increased: so this works.


2) Responses to retransmitted requests also work
------------------------------------------------
All responses that are triggered by incoming, retransmitted requests also correctly have their
sequence number incremented. 

This can be confirmed using the following scenario:
	* host A has iptables rule to drop all incoming DCCP (-p 33) packets
	* host B has a listening DCCP application and answers the requests from A
	* host A never sees any responses to its responses and retransmits until it gives up

Since retransmitted Requests work due to (1), packets enter dccp_check_req(), which
will identify `Retransmitted REQUEST' in syslog. And it will increment the sequence number:
		
	dccp_set_seqno(&dreq->dreq_iss, dreq->dreq_iss + 1);

Hence triggered Responses also work.


3) Interaction with timer
-------------------------
Since (1,2) both work, I think what Vladimir referred to was a sequence of two Responses sent
in reply to a single Request. These can indeed be observed, but have a variable difference
of time (using the test setup of (2)). Of these the first is the genuine Response, and the
second one is triggered by a timeout in dccp_response_timer(), which calls dccp_v{4,6}_send_response()
via the indirection of inet_csk_reqsk_queue_prune(). And in this case -- and this case only --
the response packets have identical sequence numbers.
Although this is a relatively minor bug, I believe it would be better to stick by the DCCP rule
that `each outgoing packet has its sequence number incremented' and will send a patch.

Ian, I will remove this ToDo from the list, ok?

Thanks to Vladimir for pointing this out; but it would in future be much more helpful to
have some real traces to work on - otherwise it really is hard to figure out the causes. 

Gerrit

