From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 07:53:48 +0000
Subject: Test tree now updated to match davem-2.6.24
Message-Id: <200708210853.48424@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have updated the test tree to track 2.6.24 with Arnaldo's brandnew interface.

These are the changes to the test tree:

1. Dropped the following patches due to new ktime_t interface:
   [CCID3]: Update computation of X to use newer timeofday interface
   => No longer necessary  :)

   [DCCP]: Simplify interface of dccp_sample_rtt
   => I have additionally updated all other code which depends on this
       one, to use the newer interface for dccp_sample_rtt, to keep it
       consistent.

2. Weeded out old cruft from "[CCID3]: Revert code shifts"
   This stuff has, as far as possible, been integrated/spread into other
   changesets. 

3. Merged the following two patches:
   [CCID 3]: New RX History Step 4 - Integrate Receiver RTT sampling (part 3 of 3)
   [CCID 3]: New RX History Step 5 - CCID3 packet reception

   into a single one:
   [CCID 3]: New RX History Step 4/5 - Integrate Receiver RTT sampling (part 3 of 3)

A diff taken against the older test tree showed that no other effects were introduced.

Please note: It seems that the 2.6.24 tree is in the middle of some merge window. It may
             happen/was experienced that the code currently not works favourably on all 
             computers, so please be patient.
