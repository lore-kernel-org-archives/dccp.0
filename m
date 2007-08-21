From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 14:22:08 +0000
Subject: Re: [RFC][PATCH 1/1]: Let dccp_epoch return
Message-Id: <200708211522.08339@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708211510.31147@strip-the-willow>
In-Reply-To: <200708211510.31147@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  The idea is to start the timer when DCCP is loaded. This gives
|  2^32-1 usecs = circa 49 days before the clock wraps around.
Oops, it is not milliseconds but microseconds ... that means the counter
wraps around every 71 seconds. If the maximum RTT is 3 seconds, then this
means wrap-around every 20 RTTs.

Maybe this is too much?
