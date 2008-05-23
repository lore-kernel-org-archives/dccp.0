From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 23 May 2008 09:28:02 +0000
Subject: Re: QUESTION: About the RFCs of DCCP
Message-Id: <20080523092802.GA8871@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <48364E35.80606@cn.fujitsu.com>
In-Reply-To: <48364E35.80606@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> It also found something does not completed implement rfc, such as the  
> two patch I had send to the mail list, and the BUG [Re: Reporting  
> possible bug in DCCP Feature negotiation]  which is reported by Leandro  
> Sales can be reproduct simplely.
>
Then it would be even more valuable to have such a tool. The bug you
referred to was hard to track down manually since it only occurred when
the Ack carrying the Confirm options was lost. I could only reproduce it
by modifying the kernel to drop the single Ack of the client completing
the 3-way handshake. With a tool, this would have been much easier.

Please do report any faults, omissions or incompleteness that you find
while testing.

- Gerrit
