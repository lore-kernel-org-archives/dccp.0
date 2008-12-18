From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 18 Dec 2008 05:56:17 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081218055617.GC6298@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > Hence your suggestion does not improve the code. I maintain that it is
| > correct. And it has proven to work in the test tree for more than one
| > year, including tests with up to 100 parallel (iperf) connections.
| 
| The read-lock is just a memory barrier here (not a read memory barrier
| as I wrote
| before) and it's not needed here. If I read the code correctly you are
| testing a single
| pointer to be NULL and don't really care about ordering wrt module
| initialization.
| 
| You can actually annotate ccids[] as read_mostly (it's changed only on module
| load/unload) and protect it with RCU instead of the home-grown rwlock
| you are using.
| 
Hm the details are not so important here. What is important is that your
observation and questioning whether the code makes sense has lead to 
finding a deeper problem. Without your posting that may not have
happened. So many thanks indeed, if you have any more observations,
please keep them coming.
