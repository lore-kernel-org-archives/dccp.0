From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Apr 2007 08:59:32 +0000
Subject: Re: [PATCH 25/25]: Add test function for data packets
Message-Id: <200704021002.47288@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211846.15696@strip-the-willow>
In-Reply-To: <200703211846.15696@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > [DCCP]: Add test function for data packets
|  >
|  
|  I presume this is for following patches as no use yet. Normally
|  patches aren't merged into kernel until there is a use for them.
Yes it is used - the CCID3 receiver tests repeatedly for data packets.
It may be useful in general too since it actually implements exactly
what RFC 4340 calls data packets.
