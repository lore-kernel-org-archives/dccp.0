From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 10 Dec 2010 12:38:34 +0000
Subject: Re: Fwd: DCCP - sysctl sequence window
Message-Id: <20101210123834.GA5727@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <AANLkTi=7_NFXUQuE0hOt+2tK-ZY2bRsc2mN0iCCdY709@mail.gmail.com>
In-Reply-To: <AANLkTi=7_NFXUQuE0hOt+2tK-ZY2bRsc2mN0iCCdY709@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| According to RFC4340 "The maximum valid Sequence Window value is Wmax | 2^46 - 1 = 70368744177663", however I could set the sequence window size
| to this value using linux kernel 2.6.36.
| I tried to do this with the command:
| sudo sysctl -w net.dccp.default.seq_windowp368744177663
| and also by modifying /proc/sys/net/dccp/default/seq_window file.
| 
| The maximum value of the seq_window I could set was 2^32-1 (4294967295).

The original commit message also mentions this value, please see further below.

-----------------------------------------------------------------------------------
commit 883ca833e5fb814fb03426c9d35e5489ce43e8da
Author: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date:   Fri Jan 16 23:36:32 2009 +0000

    dccp: Initialisation and type-checking of feature sysctls
    
    This patch takes care of initialising and type-checking sysctls
    related to feature negotiation. Type checking is important since some
    of the sysctls now directly impact the feature-negotiation process.
    
    The sysctls are initialised with the known default values for each
    feature.  For the type-checking the value constraints from RFC 4340
    are used:
    
     * Sequence Window uses the specified Wmin2, the maximum is ulong (4 bytes),
       tested and confirmed that it works up to 4294967295 - for Gbps speed;
-----------------------------------------------------------------------------------

This happened before 2.6.36, before that the type of the seq_window sysctl had been
'int' -- not much larger.

If I recall correctly, there is a reason for using 2^32-1 as upper bound:
 * the sysctl value is the initial window value for the feature negotiation;
 * using an extremely high sequence window does not (as in TCP) mean better performance,
   it increases the likelihood of getting out-of-synch between sender and receiver;
 * as in TCP, the idea is to start with a small value, which can then be dynamically
   adapted;
 * it is planned to support dynamic updates since, aside from Ack Ratio, Sequence 
   Window is the only NN feature;
 * however, more work is needed to make the dynamic case work robustly: the mainline
   kernel has set Ack Ratio (and thus implicitly Sequence Window) to 1 for ages, and
   in the test tree updating this value is also currently disabled (it does not work
   with the current CCID-2 code);
 * however, the feature negotiation code (the handlers that take the dynamic values)
   is capable of handling the 48-bit values, passing these on to update GSR/GSS;
 * hence eventually, when the issues with dynamic changes have been stabilised, it
   will be possible to use 48-bit numbers, but the initial value remains at 2^32-1.

Gerrit
