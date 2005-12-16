From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Fri, 16 Dec 2005 21:51:08 +0000
Subject: second attempt for CCID2 patches
Message-Id: <20051216215108.GA6861@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here are the new CCID2 patches:

Do not process a packet twice when it's received in a state != DCCP_OPEN.
http://darkircop.org/1

Introduce ACK vector records. [using struct list_head]
http://darkircop.org/2

Introduce CCID2.
http://darkircop.org/3
