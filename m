From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 13:09:23 +0000
Subject: Iperf CPU usage
Message-Id: <200709281409.23853@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Earlier on this list there was a thread that the CPU usage of iperf was too high (75%..95%).
Now, Ingo Molnar has found the problem:

http://marc.info/?l=linux-kernel&m9088670113210&w=2

I have tested this and the CPU usage dropped below 10%! 

Will go and add this patch before the other iperf patches and upload it to 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#iperf
