From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 Sep 2011 02:50:05 +0000
Subject: dccp test-tree [ANNOUNCE] dccp: DCCP-Cubic / CCID-5 subtree
Message-Id: <20110922025005.GA17896@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks to Ivo for implementing DCCP-Cubic (aka CCID-249, aka CCID-5).

I have added a new subtree for CCID-249 at

   git://eden-feed.erg.abdn.ac.uk/dccp_exp  [subtree `ccid5']

Patch based on net-2.6 is at
   http://eden-feed.erg.abdn.ac.uk/latest-dccp-ccid5-test-tree.diff.gz

Tarball based on net-2.6 is at
   http://eden-feed.erg.abdn.ac.uk/latest-dccp-ccid5-test-tree.tar.bz2

after fixing some whitespace issues in the patch. I will keep it in synch
with the rest of the test tree, please do send any updates you find for CCID-5.

           =====================
           Short HOWTO on installing and using CCID-5
           =====================

To clone the ccid5 tree,

   git checkout -b ccid5
   git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp +ccid5:ccid5

When recompiling the dccp module, set

   CONFIG_IP_DCCP_CCID5=y
   CONFIG_IP_DCCP_CCID5_DEBUG=y

After installation and modprobing the dccp module, set

  echo 249 > /proc/sys/net/dccp/default/tx_ccid
  echo 249 > /proc/sys/net/dccp/default/rx_ccid 

to use the CCID-5 (resp. CCID-249) module.

On 1Gbit ethernet, I measured up to 776 Mbps with iperf,
on a noisy 2.4Ghz 802.11g it was still 13.7 Mbps.

