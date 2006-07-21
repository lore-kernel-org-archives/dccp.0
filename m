From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 21 Jul 2006 02:30:49 +0000
Subject: [BUG] CCID3 - loss not detected if in order
Message-Id: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi folks,

Loss is not being detected correctly in CCID3 and p never gets to be
anything but 0.

In ccid3_hc_rx_packet_recv the loss code can only be called if
dccp_rx_hist_add_packet returns 1. This only can only return 1 if
packets are out of order. In normal loss this will never return 1. p
therefore does not get set to anything but 0.

This causes CCID3 to send packets too fast which explains some of the
behaviour I'm seeing.

I am thinking about how to fix this at the moment but as always others
are free to dive in!

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
