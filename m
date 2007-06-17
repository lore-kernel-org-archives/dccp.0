From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 11:22:04 +0000
Subject: [PATCH 0/1]: Impedance matching
Message-Id: <200706171222.04820@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As promised, I went through my patch set and isolated the
sections which overlap with recent changes made to the
TFRC/CCID3 code.

With this patch, all the new functionality becomes available.
I have cross-checked it this against the old variant and it
works fine.
