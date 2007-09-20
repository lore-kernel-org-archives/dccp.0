From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 20 Sep 2007 11:15:57 +0000
Subject: [PATCH 0/5] CCID 4: initial implementation of CCID 4
Message-Id: <20070920111557.GA1288@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Re-submitting, with hopefully proper tags etc.


After discussing the topic on IRC, we figured we need a place to have
the sources for CCID 4 available for everyone. This way we can finally
start cooperating on it.

I have created a few patches against dccp-exp. Even if they're not much,
or pretty, they may be something to start with.

The sources are based on ~a week old copy of CCID 3 from dccp-exp,
created with
	http://wnd.katei.fi/dccp/files/copy-ccid3-to-ccid4.sh


Patch #1: Adds DCCPC_CCID4 to include/linux/dccp.h, and initial entries
	about CCID 4 to net/dccp/ccids/{Kconfig,Makefile}.

Patch #2: Clones ~a week old implementation of CCID 3 into ccid4.[ch].

Patch #3: Implements TFRC-SP's 10 ms minimum sending rate (without
	possibility to decrese inter-packet interval below 10 ms, but
	still sending at most three packets every 30 ms).

Patch #4: Reduces allowed sending rate by a factor that accounts for
	packet header size.

Patch #5: Uses nominal segment size of 1460 bytes in TCP throughput
	equation.

