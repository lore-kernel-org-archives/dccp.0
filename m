From: Patrick McHardy <kaber@trash.net>
Date: Mon, 07 Apr 2008 22:45:33 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <47FAA40D.7010905@trash.net>
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> I have had a look at the connection-tracker and it proved a valuable exercise in re-reading the specs.
> 
> Some comments itemised below.

Thanks a lot for your review :)

>  * nf_conntrack_proto_dccp.c:
>    - 8.1.2. Client Request 
>      o reference is 8.1.1, not 8.1.2

Fixed, thanks.

>      o the Linux implementation uses same method as TCP handshake
>        (and is currently the only available DCCP implementation),
>        so can probably reuse TCP timeout values here -- the rules
>        in RFC 4340 are not exactly clear.

We try not to be implementation specific (people might still be
using this once more implementations have appeared), so keeping
the larger timeout seems safer. It doesn't really hurt since
the connection will get evicted under pressure as long as it
hasn't moved to PARTOPEN with a correct ACK sequence number.
Something more specific in the RFC would be nice though.

>    - typo: state transistion table
>            OPEN: RPcket

Thanks, fixed already in my tree.

>  * just curious about timeout for OPEN state: it is set to 
>    a full working week (5 * 24 * 3600 seconds). There is this
>    wrap-around of DCCP timestamps after 11.2 hours, so maybe
>    the Open state can be curtailed.

I just copied this part from the TCP helper because I didn't
find a better value. Does the wraparound affect the maximum
lifetime of a connection? Maybe it would make sense to decrease
it in any case, I would expect applications using DCCP not
to idle as long as TCP connections might.

>  * Ignoring Sync/SyncAck packets: if this means they can get
>    through, then it is good, since for instance CCID-2 may use
>    a Sync for out-of-band information; RFC 4340 mentions Syncs
>    for similar purposes (e.g. feature negotiation); and Syncs
>    can appear in both directions.

Yes, ignored packets just never cause state transistions.

>  * for the timeout sysctls, use proc_dointvec_ms_jiffies ?

I chose seconds because its consistent with what other conntrack
protocols use and less likely to confuse users.

>  * the state table has dimension DCCP_PKT_SYNCACK + 1, but what if 
>    a value greater than that appears in the dccp header in the statement
>    state = dccp_state_table[IP_CT_DIR_ORIGINAL][dh->dccph_type][CT_DCCP_NONE];

All packets go through dccp_error() first, which catches invalid
packet types.

>  * dccp_ack_seq() duplicates code from include/linux/dccp.h:
>    could use dccp_hdr_ack_seq() instead.

Yes, this is something I still wanted to look into. The reason
why its duplicated is that the DCCP protocol functions assume
skb->transport_header to point to the DCCP header. This is
only true for packets in the protocol layer.

> 	State Transitions in the original direction
> 	=====================> 
>  * DCCP-Request:
>    - in state Respond (sRS -> sRS), the Request is illegal (Respond is server state)

Yes, this is one of the differences that comes from sitting in
the middle :) In the reply direction we transition from sRQ to
sRS when receiving a Response. However, that response might not
make it to the client or simply be late, in which case the request
is retransmitted.

Generally, for all states that exist only on one side (and we
transistion to it even if the packet might never reach the other
side), we must accept all packets in the other direction as in
the previous state.

>    - also, the CLOSEREQ state transition (sCR -> sIG) is illegal: Requests are sent 
>      by clients only, and CLOSEREQ can only be entered by servers

We track both sides, so we must also define which client packets
are valid in which server state. This particular one is part of
the unfinished resync feature. The firewall might be out of sync
with both endpoints. If connection pickup is enabled it should
let packets that might establish a new connection pass and resync
when the other side responds with a valid Response. I need to
think about this a bit more, but I've marked it with FIXME for
now :)

>    - timewait transition -- question: is it possible to re-incarnate a new connection
>      here instead of ignoring the (new) Request?

Yes, I'll change this. The tricker case is a reincarnation in the
reverse direction. The conntrack entry must be killed and recreated
since the state table is directional and the client/server roles
change. Also needs a bit more thought.

>  * DCCP-DataAck:
>    - the transition sRS should go to sPO (Partopen). This is because the client
>      can send data when it has received the Response from the server, i.e. it
>      is the same rule as for DCCP-Ack in state sRS (cf. RFC 4340, 8.1.5). The "Ack"
>      in the DataAck has the same effect as an Ack in sRS, it acknowledges the 
>      Response and thus triggers transition to Partopen.

Thanks, fixed.

> 	State Transitions in the reply direction
> 	====================
> 
>  * DCCP-CloseReq:
>    - the transition from sCG is a simultaneous-close, which is possible
>      (both sides performing active-close, server sends CloseReq after client has
>       sent a Close) and has been seen on the wire, cf.
>       http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/ )
>    - use "ignore" here?

In case the client needs to respond with another Close it should
probably move to sCR. Otherwise I'd change it to stay (explicitly)
in sCG. Ignore is mainly for resyncing.

>  * DCCP-Close:
>    - the transition sCR -> sCG: I wonder if that is possible --
>      o if the client is behind the NAT, it means the server sent a Close after
>        a CloseReq, which is invalid
>      o but if (hopefully soon) a server is behind a NAT, this would mean that 
>        the server had previously sent a CloseReq which now crosses paths with
>        a Close from the client in the reverse direction -- again a simultaneous
>        close, in this case sCR -> sCR would be possible

NAT shouldn't make any difference for the states. The table is
directional, so the Close transistion here is always a Close
after a CloseReq from the server, so its also invalid.

>      o simplest option - maybe better to use sCR -> sIG or drop packet.

IIRC I used sCG because I couldn't figure out whether its
valid :) I'll change it to INVALID.

Thanks again for your review.
