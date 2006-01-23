From: Ian McDonald <imcdnzl@gmail.com>
Date: Mon, 23 Jan 2006 23:14:15 +0000
Subject: Bug?? out of memory on receive for DCCP
Message-Id: <cbec11ac0601231514g4d53131dl47bbaafb2997d110@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When I have been doing some stress testing on DCCP for my transmit
changes using ttcp with a million packets I'm getting page allocation
failures etc on the receive side (in code I haven't changed). I can
also see memory going up dramatically when viewing through "top"

Setup is two PCs on a LAN. I'm presuming this is because we don't put
limit on receive buffers at present and ttcp is not pulling packets
fast enough off buffers to stop memory exhausation.

Is that correct?

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
