From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Jul 2007 15:22:32 +0000
Subject: [PATCH 0/2]: Abortive release in DCCP
Message-Id: <200707131622.32569@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds support for aborting a DCCP connection
and completes the patch set concerning closing/aborting connections

Patch #1: Checks for unread data at the end of a connection and warns otherwise.

Patch #2: Implements the analogue of the TCP ABORT function
