From: Giuseppe Galeota <giuseppegaleota@libero.it>
Date: Mon, 26 May 2008 11:53:02 +0000
Subject: Experimental_DCCP_source_tree: Snapshot patch for kernel 2.6.24
Message-Id: <483AA49E.2000804@libero.it>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,
I have followed the guide from 
http://www.linux-foundation.org/en/Net:DCCP_Testing in order to use the 
Monitoring DCCP.
I also need to apply the web100 patch, that is valid only for a kernel 
2.6.*24* (http://www.web100.org).

So, I have downloaded the kernel 2.6.24 from 
http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.24.tar.gz, and I 
applied the web100 patch (that is, 
web100-2.6.24-2.5.19-200802211940.patch , downloaded from 
http://www.web100.org). This is OK.
After that, I tried to enable the Experimental_DCCP_source_tree using 
the Snapshot patch, that I have downloaded from 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/test-tree_2.6.24.diff.gz, 
but  without success.
(If you want, I can post the result).

I also tried to apply the web100 patch to the kernel ( or nigthly 
snapshot of the DCCP tree ) downloaded from 
http://eden-feed.erg.abdn.ac.uk/latest-dccp-test-tree.tar.bz2, but 
without success.

Have you suggestions to resolve this situation?

Giuseppe Galeota
