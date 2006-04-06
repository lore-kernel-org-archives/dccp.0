From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 06 Apr 2006 10:19:24 +0000
Subject: DCCP test-suite
Message-Id: <20060406101924.GA2689@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

i'm developing a DCCP test-framework.  Hopefully it is platform independent
enough so that even BSD implementations can benefit from it.

I always thought it would be a neat idea, but after writing a couple of tests,
it turned out to be actually useful.  The current tests isolate 3 bugs in the
Linux implementation.

For more information:
http://tapir.cs.ucl.ac.uk/pccd/
[trailing slash is important]


It would be nice to receive feedback on:
* API of tests... what should tests look like?
* Is there a way to generate tests?
* What test cases to build?
* whatever...
* a name for this thing
