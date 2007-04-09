From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 09 Apr 2007 09:58:34 +0000
Subject: [PATCH 0/5]: Sync/Reset Floods; Rate-Limiting for DCCP-Sync
Message-Id: <200704091058.35064@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch set fixes two bugs and adds rate-limiting for DCCP-Syncs.

Patch #1: Uses variables instead of a reference to skb fields;
          it is needed by patch #2 (no code change here).

Patch #2: Fixes the Sync/Reset flood bug discussed earlier on
          dccp@vger, by adding the special case for sequence-invalid
          Reset from RFC 4340, 7.5.4.

Patch #3: Renames `seq' parameter of dccp_send_sync into `ackno'.

Patch #4: Implements rate-limiting for DCCP-Syncs.

Patch #5: Adds another exception required by RFC 4340, 7.5.4 -
          In state REQUEST, receiving a Sync generates a Reset and
          not a SyncAck.
