From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 20 Jun 2007 09:55:17 +0000
Subject: [PATCH 0/5][BUG-fix]: Sync-Flood Fixes
Message-Id: <200706201055.17078@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo asked me to send these, they have been made independent of the patches in the 
test tree (but will be made available for review).

Patch #1: Cosmetics, but required by other patches - shortens many occurrences of
          very long variable names.

Patch #2: Reset/Sync-Flood Bug fix. 
          The bug has been known for a long while (I recently found an email from Ian
          who mentioned it as early as December), a previous discussion with Eddie helped
          to track down where the bug originates. Patch has detailed description of how
          bug is triggered, and fixes the described symptom.

Patch #3: Renames parameter for clarity (was confusing).

Patch #4: Rate-Limit DCCP Syncs. This is recommended in RFC 4340 and from own experience
          I found that rate-limiting alone can terminate oscillating Sync message exchanges,
          i.e. it increases resilience against malfunction and attacks.
 
Patch #5: Second bug - in REQUEST state, a Reset is sent in response to Sync, not SyncAck.
