From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Tue, 28 Feb 2006 23:18:31 +0000
Subject: [BUG] DCCP : Suspected race in ackvec code
Message-Id: <cbec11ac0602281518uc14fe5fl73eda47b211a7d9f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When send_ackvec sysctl is on DCCP locks the machine. Unfortunately it
doesn't send any output to the kernel.

Test cases:
On receive end (10.0.2.2):
./ttcp_acme -c -l500 -r

On send end (10.0.7.7):
./ttcp_acme -c -l500 -n1000 -t 10.0.2.2

And the setup on 10.0.5.5 (which provides a route between 10.0.2.2 and
10.0.7.7) is:

tc qdisc add dev eth0 root netem delay 50ms loss 10%
tc qdisc add dev eth1 root netem delay 50ms loss 10%

Passes:
echo 0 > /proc/sys/net/dccp/default/send_ackvec
echo 3 > /proc/sys/net/dccp/default/rx_ccid
echo 3 > /proc/sys/net/dccp/default/tx_ccid

Locks the machine:
echo 1 > /proc/sys/net/dccp/default/send_ackvec
echo 3 > /proc/sys/net/dccp/default/rx_ccid
echo 3 > /proc/sys/net/dccp/default/tx_ccid

Locks the machine:
echo 1 > /proc/sys/net/dccp/default/send_ackvec
echo 2 > /proc/sys/net/dccp/default/rx_ccid
echo 2 > /proc/sys/net/dccp/default/tx_ccid

Doesn't lock the machine but doesn't complete the test:
echo 0 > /proc/sys/net/dccp/default/send_ackvec
echo 2 > /proc/sys/net/dccp/default/rx_ccid
echo 2 > /proc/sys/net/dccp/default/tx_ccid

The only reason I say that there is a race is that the problems are
similar to when I had races without proper locking when implementing
tx buffering. When you inject delay/loss with netem it triggers a lot
more code coverage because timers get fired, data is missing etc.

I've had a quick look around but can't find it yet - I find these
races quite nasty to find but will keep looking at it over as time
permits...

Ian
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
