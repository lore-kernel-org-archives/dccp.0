From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 10 Jan 2007 09:03:04 +0000
Subject: Re: AUDIT: Safe usage of before48/after48 in the DCCP code
Message-Id: <200701100903.04524@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701081300.15691@strip-the-willow>
In-Reply-To: <200701081300.15691@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > 		1) General cases
|  > 		========
|  
|  Thanks for doing the audit!
|  
|  > CASE 1: calls of the form 
|  > 	 * if (before48(a,b)) or 
|  > 	 * if (after48(b,a))
|  >         are not ambiguous due to the definition of before48 (see above link for details).
|  
|  Actually,
|  
|  	if (before48(a, b))
|  
|  is ambiguous if and only if
|  
|  	if (!before48(a, b))
|  
|  is ambiguous.  
The new definition of `before48' is identical to the old one apart from all those
pairs a,b whose distance is 2^47 - the ambiguous case, which is now included in !before.

|  Whether it's safe depends on the clause after the if 
|  statement, i.e.,
|  
|  	if (before48(a, b))
|  		process_packet();
|  
|  would be safe while
|  
|  	if (before48(a, b))
|  		drop_packet();
One could consider this in terms of the first as
	if (!before48(a, b))
		process_packet();

Thanks for the comments - I therefore went again through the list of cases. I found two instances which are
of the form you described:

net/dccp/ccids/lib/packet_history.c-225-        if (!list_empty(li_list)) {
net/dccp/ccids/lib/packet_history.c-226-                list_for_each_entry_safe(entry, next, rx_list, dccphrx_node) {
net/dccp/ccids/lib/packet_history.c-227-                        if (num_later = 0) {
net/dccp/ccids/lib/packet_history.c:228:                                if (after48(nonloss_seqno,
net/dccp/ccids/lib/packet_history.c-229-                                   entry->dccphrx_seqno)) {
net/dccp/ccids/lib/packet_history.c-230-                                        list_del_init(&entry->dccphrx_node);
net/dccp/ccids/lib/packet_history.c-231-                                        dccp_rx_hist_entry_delete(hist, entry);
=> This is part of the synchronous garbage collection for the RX history (function dccp_rx_hist_add_packet).
    We would have an ambiguity in the case where entry->dccphrx_seqno and nonloss_seqno are 2^47 apart:
	* with the old definition the entry would be cleared
	* with the new definition the entry would not be cleared
    I am arguing that this instance is benign: the entry would not be cleared now; but the condition would be
    satisfied the next time when dccp_rx_hist_add_packet is called - with a higher value of nonloss_seqno. So
    the difference is that in this special case the entry would be cleared slightly later, but eventually it will.

net/dccp/ackvec.c:60:           BUG_ON(before48(avr->dccpavr_ack_seqno,
net/dccp/ackvec.c-61-                           head->dccpavr_ack_seqno));
=> As in the other instance of Ack Vectors, a sequence number distance of 2^47 is not within the scope of what Ack
    Vectors are used for, it is a pathological case.
