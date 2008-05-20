From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 20 May 2008 17:01:01 +0000
Subject: [Announce]: DCCP Test Tree tarballs
Message-Id: <20080520170101.GA25922@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

To make it easier to use the test-tree, daily snapshote are now available at

 wget http://eden-feed.erg.abdn.ac.uk/latest-dccp-test-tree.tar.bz2

Apparently snapshot patches didn't work so well, this allows a
consistent and up-to-date tree (~50 MB).

Please note: this uses `git-archive' format, i.e. you will need to create
             a separate directory first, e.g.

             mkdir test-tree; cd test-tree; tar -jxvf ../latest-*tar.bz
