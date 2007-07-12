From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Jul 2007 14:20:48 +0000
Subject: [PATCH 0/10]: Support for passive close
Message-Id: <200707121520.48349@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am sending the last two batches in my current patch set; both
are concerned with ensuring correct behaviour on closing a DCCP
connection. This requires the use of intermediate states, details
are described on 

http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/

Patch  #1: Separates the list of DCCP protocol states into connection-oriented generic
           states and DCCP-specific states.

Patch  #2: Makes PARTOPEN autonomous (addressing a FIXME in the list of states).

Patch  #3: Introduces the two dedicated intermediate/auxiliary states 
           PASSIVE_1 and PASSIVE_2, which are the basis of the entire patch set (cf. url).

Patch  #4: Implements the basic state transitions featuring PASSIVE_1/2.

Patch  #5: DCCP does not support half-close (RFC 4340), thus this patch performs SHUT_WR in 
           addition to SHUT_RD (as done previously).

Patch  #6: Is analogous to patch #5: since DCCP does not support half-close, the state
           DCCPF_CLOSING is removed in the opening statement of dccp_sendmsg().

Patch  #7: Shifts the retransmit timer for active-close into output.c and uses the RFC 4340
           fallback RTT value to set the timeout.

Patch  #8: Realises the maximum-RTO backoff from the DCCP specification.

Patch  #9: Implements support for Server holding TIMEWAIT state as per RFC 4340, 8.3.

Patch #10: Collapses 4 repeated statements of the same kind into one.


I will send the other part, which concerns aborting a connection, tomorrow.
