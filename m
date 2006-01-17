From: Ian McDonald <imcdnzl@gmail.com>
Date: Tue, 17 Jan 2006 03:25:05 +0000
Subject: printk in net/dccp/ackvec.c
Message-Id: <cbec11ac0601161925w66fd404bsb61250824e4e485e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo,

When tracking down something else I notice that you have some printk's
without priority level (e.g. no KERN_DEBUG).

You may wish to tidy up when working on this next...

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
