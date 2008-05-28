From: Giuseppe Galeota <giuseppegaleota@libero.it>
Date: Wed, 28 May 2008 11:30:23 +0000
Subject: Monitoring DCCP: modprobe dccp_probe
Message-Id: <483D424F.5020307@libero.it>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dear Gerrit,
thanks for all, but now I have a new problem.
I need to enable Monitoring DCCP as here 
http://www.linux-foundation.org/en/Net:DCCP_Testing#Monitoring_DCCP
So, I make:

sudo modprobe dccp
sudo modprobe dccp_ccid3
sudo sysctl -w net.dccp.default.rx_ccid=3
sudo sysctl -w net.dccp.default.tx_ccid=3

and this is OK, but when I make:

modprobe -v dccp_probe


I have follow message:

zazze@zazze-portatile:~$ sudo modprobe -v dccp_probe
FATAL: Module dccp_probe not found.


Have you suggestions?

Giuseppe



