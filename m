From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 31 Jan 2008 13:41:38 +0000
Subject: CCID3 over WiFi Study
Message-Id: <20080131134138.GA13260@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have uploaded an annotated set of plots on CCID3 over WiFi on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/ccid3_over_wifi/

The interest was to get away from emulated networks. The WiFi link provides
a real-world scenario which will create loss (100Mbs feeding into 11Mbps).

Note: While doing these tests several more bugs in iperf (DCCP mode) were
      found (and fixed). The improved variant will be uploaded soon.

Gerrit
-- 
