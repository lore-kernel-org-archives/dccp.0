From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Jan 2007 08:41:32 +0000
Subject: [PATCH-UPDATE]: 3d_CCID3_fix_tardiness-BUG.diff
Message-Id: <200701150841.32111@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As a result of the present discussions, I have dropped patch "3d" which resets
t_nom to t_now when packets start to get late. 

Note that this still does not resolve the problem that the scheduling of packets is
unpredictable and seemingly uncontrollable.

The packet scheduling needs more revision, in particular for the case when X gets
closer to 

            X_crit   =   packet_size_in_bytes * HZ
