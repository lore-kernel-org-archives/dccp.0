From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Dec 2006 09:03:09 +0000
Subject: Re: [PATCH] BUG-FIX - conversion errors
Message-Id: <200612110903.09925@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612081532.21104@strip-the-willow>
In-Reply-To: <200612081532.21104@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  Do we calculate mss anywhere?
Yes there is support in dccps_mss_cache .
At the begin of dccp_send_msg e.g. it is used. 

I have thought about `s' vs. MSS and it is really stupid not to use MSS
 -- if `s' is e.g. 20 bytes, one can only send 40 ... 80 bytes per RTT
 -- with jumbo ethernet cards the MTU can be as high as 10k -- a multiple of 20 bytes :)

Gerrit
