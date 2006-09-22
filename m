From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Sep 2006 17:28:01 +0000
Subject: Re: [PATCH 5/7] [DCCP]: Introduce two new socket options
Message-Id: <200609221828.02122@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609221430.14555.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221430.14555.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Eddie,

|  The "intended average packet size", a congestion control parameter used by 
|  CCID 3 and CCID 4, is different from the actually _observed_ packet size.  I 
|  could see how an explicit setting for this congestion control parameter might 
|  be useful in addition to the information communicated by 'len' and incoming 
|  packet sizes.
|  
|  CCID 3, for example, says that 's' MAY be calculated from a running average, 
|  OR from the maximum segment size.  I think an option like 
|  DCCP_SOCKOPT_TX_PACKET_SIZE, by which the app can declare an intended average 
|  packet size, is also acceptable.
It is acceptable but not useful. The kernel module already has the information
available to derive `s' in either way:
  * it knows the maximum segment size (which a user would have to retrieve via another
    socket option call)
  * it has information about packet header lengths and option lengths
  * it can track the average of past payload lengths

Why burden the application programmer to handcode an estimation of the average each
time? I can not see a justification for this, certainly not for CCIDs which
are intended to be used with (on average) fixed packet sizes.

I think that a priority is to keep the user programming interface as simple as
possible -- like UDP's interface, as stated in RFC 4340.

|  > In summary, I think it would be better to let the sender/receiver determine the 
|  > packet size from already available data. That is, derive s from the `len' of dccp_sendmsg(),
|  > and use a weighted-average mechanism like
|  >                        s  =   q * len  +  (1-q) * s
|  > to smooth out variations: in accordance with draft-floyd-rfc3448bis-00.
|  
|  This would be fine with me, and perhaps even preferable in terms of the 
|  programming API.  But the drafts I think would allow the socket option, so if 
|  it's needed now, why not?
To encourage programmers to use DCCP by providing a simple-to-use programming API with a minimal
set of required options to program into the application code.

Gerrit
