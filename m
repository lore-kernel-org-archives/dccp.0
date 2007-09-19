From: Tommi Saviranta <wnd@iki.fi>
Date: Wed, 19 Sep 2007 08:16:35 +0000
Subject: Source repository for CCID 4
Message-Id: <20070919081635.GA26986@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

After discussing the topic on IRC, we figured we need a place to have
the sources for CCID 4 available for everyone. This way we can finally
start cooperating on it.

I have created a few patches against dccp-exp. Even if they're not much,
or pretty, they may be something to start with.

Complete patch can be found at
	http://wnd.katei.fi/dccp/files/ccid4_2007-09-19.diff

The sources are based on ~a week old copy of CCID 3 from dccp-exp,
created with
	http://wnd.katei.fi/dccp/files/copy-ccid3-to-ccid4.sh

There also exists a patch against created ccid4.[ch] (without necessary
changes to include/linux/dccp.h, net/dccp/ccids/Kconfig, and
net/dccp/ccids/Makefile) at
	http://wnd.katei.fi/dccp/files/ccid4.c.h_2007-09-19.diff


And what exactly is the deal, or convention, with Signed-off-by at
dccp-exp?
