From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 11:07:56 +0000
Subject: Re: [PATCH 9/9]: API to query the current TX/RX CCID
Message-Id: <200710021207.56213@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.35654@strip-the-willow>
In-Reply-To: <200709281630.35654@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > [DCCP]: API to query the current TX/RX CCID
|  >
|  > This provides function to query the current TX/RX CCID dynamically, without
|  > reliance on the minisock value, using dynamic information available in the
|  > currently loaded CCID module.
<snip>
|  
|  I presume this is to support more CCIDs in future as currently makes
|  the code more complicated...
The benefits are not visible in this patch - the tx_ccid/rx_ccid members of the
minisock are removed in a future patch, and from then on CCIDs are fully dynamic.
