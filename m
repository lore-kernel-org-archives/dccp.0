From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 20 Feb 2012 21:09:32 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <20120220210932.GA4658@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Jordi,

sorry it has taken a while to answer. I would like to follow this bug report up
and replace the BUG_ON() with one or more warnings and/or BUG_ON()s in other
places. This will take some time, probabably nearer the end of week.

With regard to your reply, here are some thoughts:

 a) 64-bit number truncation issues
    Part of my testing is an older Core Due T2400 32 bit x86 laptop. If your
    architecture is fully x86 compatible, it looks as if the truncation
    issues are unlikely.
    One way of verifying this is to build a test module, and test how it
    is computing 64-bit values (division and shifting). But if that were the
    case, it would also show up in other parts, hence I think that 64/32 bit
    conversion is an unlikely cause. I.e. I fully agree with your point.

 b) Sending 1/2 byte packets
    I will look into this again, just to make sure it does not create a problem.

This so far leaves tx_s as a possible cause of the problem. My previous reply was
not quite correct, I was thinking of sources that could set tx_s to 0, but which
are in the test tree kernel version.

Lastly, it is still quite possible that this is some bug or interaction which has
been fixed in the test tree changeset. 

To enable debugging, could you please set
CONFIG_IP_DCCP_DCCP_DEBUG=y
CONFIG_IP_DCCP_CCID3_DEBUG=y

which compiles the dccp module with debug information, and then enable debugging via

 echo Y > /sys/module/dccp/parameters/ccid3_debug
 echo Y > /sys/module/dccp/parameters/dccp_debug

Hopefully that will shed some more light on the issue. Will be back when there are news.

Gerrit
