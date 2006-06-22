From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 18:03:42 +0000
Subject: ccid2 status [and a graph for the nets ppl =D]
Message-Id: <20060622180342.GL4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I sent some patches to this list which should make CCID2 behave better.  For
people out there that want to play with CCID2, I added code which enables
user-land applications to track the state of CCID2.  Here is a graph I obtained
when running CCID2 between two boxes on a 100Mbit network [no delay, just "lan
delay"].
http://darkircop.org/vger.png
If you are interested in this particular aspect [monitoring CCID2] send me a
mail and I'll give you info and tools.

CCID2 seems to work in this scenario.  It doesn't quite work when you add delay.
I will sort that out next.  But now I gotta do some other stuff.
