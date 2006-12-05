From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 20:19:32 +0000
Subject: CCID 3 performance - some further thoughts
Message-Id: <200612052019.32837@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have been experimenting with CCID 3 on various computers,
below is a list of observations:

 * I didn't use netem or anything (no loss), yet the receiver reported loss
   
 * I quite frequently got those messages from tfrc_calc_x, like

   tfrc_calc_x: Value of p (29) below resolution. Substituting 100

   This should not happen - I believe that these p measurements are bogus
   and we should check if the loss rate computation is ok.

 * the behaviour of iperf is very unpredictable, sometimes it seems that
   throughput is directly related to current system load

 * the RTT values are almost always higher than the RTT computed by ICMP
   ping - highly desirable to find ways of obtaining sharper estimates

 * would it make sense to define an RTT cut-off value, such as e.g. 2MSL
   (120 seconds) and regard all RTT estimates above this value as nonsensical?
   E.g.: #define DCCP_SENSIBLE_RTT_VALUE_MAX 120 * USEC_PER_SEC

- Gerrit
