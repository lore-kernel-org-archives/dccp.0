From: Burak Gorkemli <burakgmail-dccp@yahoo.com>
Date: Mon, 21 May 2007 09:32:36 +0000
Subject: problem with CCID3 loss events
Message-Id: <9442.39900.qm@web30009.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

I did some CCID3 tests lately with 2.6.20final_dccp (2.6.20 with Ian's patches applied - not the latest patches BTW, the ones in http://wand.net.nz/~iam4/dccp/patches20/). From the tests, I realized that DCCP behaves OK when there is no loss. However, when packets are started to be lost, DCCP nearly shuts itself down and can barely send any packet for a time. I suspect there is something wrong with the loss rate calculation. Any comments on this?

A detailed report is available in http://home.ku.edu.tr/~bgorkemli/dccp/DCCP_Tests.htm

Burak


