From: Patrick McHardy <kaber@trash.net>
Date: Tue, 08 Apr 2008 10:30:58 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <47FB4962.60300@trash.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000402050100020607070600"
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--------------000402050100020607070600
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Gerrit Renker wrote:
> I have not a big understanding of netfilter and so got several things
> wrong in the last posting. Thank you for patience in clarifying these.
> 
>>>  * just curious about timeout for OPEN state: it is set to    a full 
>>> working week (5 * 24 * 3600 seconds). There is this
>>>    wrap-around of DCCP timestamps after 11.2 hours, so maybe
>>>    the Open state can be curtailed.
>> I just copied this part from the TCP helper because I didn't
>> find a better value. Does the wraparound affect the maximum
>> lifetime of a connection? Maybe it would make sense to decrease
>> it in any case, I would expect applications using DCCP not
>> to idle as long as TCP connections might.
>>
> DCCP uses a clock with a resolution of 0.00001 seconds (RFC 4340, 13.1).
> It thus wraps around much faster than the TCP suggestion of using 1ms
> timestamps (RFC 1323, 4.2.2(b)) that wrap around every 24.8 days.
> 
> It seems like this: timestamp is a 4-byte number, the 2^32 numbers need
> to be split into two halves ("before", "after"), each number stands for
> 10 microseconds, so the maximum timespan without wrap-around is about
> 5.96 hours. When the timespan is longer than that, "after" can become
> "before", i.e. there will be a glitch in RTT estimation and other parts
> that rely on timestamps. The full wrap-around, where the clock reaches
> the same value again, is after 11.9 hours.
> 
> However, the question is already resolved by the module's sysctl for
> the Open state.


I've changed the default timeout for OPEN to 12 hours.

>>> 	State Transitions in the original direction
>>> 	===========================================
>>>
>>>  * DCCP-Request:
>>>    - in state Respond (sRS -> sRS), the Request is illegal (Respond is server state)
>> Yes, this is one of the differences that comes from sitting in
>> the middle :) In the reply direction we transition from sRQ to
>> sRS when receiving a Response. However, that response might not
>> make it to the client or simply be late, in which case the request
>> is retransmitted.
>>
> Yes that was my error and the transition is clearly correct.
> 
> I have a question regarding the original direction - currently it is
> linked to the client which actively initiates a connection. DCCP 
> suffers from the problem that peer-to-peer NAT traversal is not
> really possible just because of this client/server division. There
> is a proposal which effects a pseudo simultaneous open, by letting
> the server send an initiation packet, to fix this problem (TCP
> peer-to-peer NAT traversal also favours simultaneous-open). I wonder
> if this would be possible, but it is really a future-work question.

Yes, that should be possible. But how does the server know that
the client intends to initiate a connection?

>>> 	State Transitions in the reply direction
>>> 	========================================
>>>
>>>  * DCCP-CloseReq:
>>>    - the transition from sCG is a simultaneous-close, which is possible
>>>      (both sides performing active-close, server sends CloseReq after client has
>>>       sent a Close) and has been seen on the wire, cf.
>>>       http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/ )
>>>    - use "ignore" here?
>> In case the client needs to respond with another Close it should
>> probably move to sCR. Otherwise I'd change it to stay (explicitly)
>> in sCG. Ignore is mainly for resyncing.
>>
> Staying in sCG makes sense, in particular since RFC4340, 8.3 asks that a
> Close must be sent in reply to each CloseReq (even when in state Closing).
> So the client would retransmit its Close, which again would leave it in
> sCG. When the server gets the second Close, it may already have received
> the first one, thus it will respond with a Reset, Code 3 ("No Connection"),
> which would then resolve the simultaneous-close into sTW.    

In that case sCR makes most sense since in that state we're
expecting a Close from the client.

The attached patch contains the changes I've made so far
based on your review. I'll go through the remaining points
now.

--------------000402050100020607070600
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 44c8aa6..8509278 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -70,7 +70,7 @@ static unsigned int dccp_timeout[CT_DCCP_MAX + 1] __read_mostly = {
 	[CT_DCCP_REQUEST]	= 2 * DCCP_MSL,
 	[CT_DCCP_RESPOND]	= 4 * DCCP_MSL,
 	[CT_DCCP_PARTOPEN]	= 4 * DCCP_MSL,
-	[CT_DCCP_OPEN]		= 5 * 86400 * HZ,
+	[CT_DCCP_OPEN]		= 12 * 3600 * HZ,
 	[CT_DCCP_CLOSEREQ]	= 64 * HZ,
 	[CT_DCCP_CLOSING]	= 64 * HZ,
 	[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL,
@@ -142,12 +142,12 @@ dccp_state_table[IP_CT_DIR_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
 		 * 			got lost after we saw it) or reincarnation
 		 * sPO -> sIG		Request during PARTOPEN state, server will ignore it
 		 * sOP -> sIG		Request during OPEN state: server will ignore it
-		 * sCR -> sIG		MUST respond with Close to CloseReq (8.3.)
+		 * sCR -> sIG		FIXME MUST respond with Close to CloseReq (8.3.)
 		 * sCG -> sIG
-		 * sTW -> sIG		Time-wait
+		 * sTW -> sRQ		Reincarnation
 		 *
 		 *	sNO, sRQ, sRS, sPO. sOP, sCR, sCG, sTW, */
-			sRQ, sRQ, sRS, sIG, sIG, sIG, sIG, sIG,
+			sRQ, sRQ, sRS, sIG, sIG, sIG, sIG, sRQ,
 		},
 		[DCCP_PKT_RESPONSE] = {
 		/*
@@ -188,7 +188,7 @@ dccp_state_table[IP_CT_DIR_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
 		/*
 		 * sNO -> sIV		No connection
 		 * sRQ -> sIV		No connection
-		 * sRS -> sIV		No connection
+		 * sRS -> sPO		Ack for Response, move to PARTOPEN (8.1.5.)
 		 * sPO -> sPO		Remain in PARTOPEN state
 		 * sOP -> sOP		Regular DataAck packet in OPEN state
 		 * sCR -> sCR		DataAck in CLOSEREQ MAY be processed (8.3.)
@@ -196,7 +196,7 @@ dccp_state_table[IP_CT_DIR_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
 		 * sTW -> sIV
 		 *
 		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
-			sIV, sIV, sIV, sPO, sOP, sCR, sCG, sIV
+			sIV, sIV, sPO, sPO, sOP, sCR, sCG, sIV
 		},
 		[DCCP_PKT_CLOSEREQ] = {
 		/*
@@ -320,7 +320,7 @@ dccp_state_table[IP_CT_DIR_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
 		 * sPO -> sOP -> sCR	Move directly to CLOSEREQ (8.1.5.)
 		 * sOP -> sCR		CloseReq in OPEN state
 		 * sCR -> sCR		Retransmit
-		 * sCG -> sIV		Already closing
+		 * sCG -> sCR		Simultaneous close, client sends another Close
 		 * sTW -> sIV		Already closed
 		 *
 		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
@@ -333,7 +333,7 @@ dccp_state_table[IP_CT_DIR_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] = {
 		 * sRS -> sIV		No connection
 		 * sPO -> sOP -> sCG	Move direcly to CLOSING
 		 * sOP -> sCG		Move to CLOSING
-		 * sCR -> sCG		Waiting for close from client
+		 * sCR -> sIV		Close after CloseReq is invalid
 		 * sCG -> sCG		Retransmit
 		 * sTW -> sIV		Already closed
 		 *

--------------000402050100020607070600--
