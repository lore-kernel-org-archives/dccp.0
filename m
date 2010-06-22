From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Jun 2010 11:14:33 +0000
Subject: [PATCH 0/2] dccp: fix slow slow-start by symmetric Syn-RTT
Message-Id: <1277205275-5862-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This changeset fixes slow startup behaviour for DCCP streaming via
CCID-3/4 when a listening server needs to start streaming.

Patch #1: removes an unused 'sk' argument from several functions,
          it is used by patch #2;

Patch #2: fixes the sluggish slow-start problem by taking an RTT
          sample from the initial handshake also for listeing servers.
