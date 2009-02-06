From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 06 Feb 2009 06:41:39 +0000
Subject: Re: Get Current CCID
Message-Id: <20090206064139.GA3718@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorry for the delay which was caused by illness.

| Gerrit,
|    consider this:
|      getsockopt (so, SOL_DCCP, DCCP_SOCKOPT_RX_CCID, &ccid, &ccidlen);
| 
|    Is there any reason for getsockopt is returning 255? This is
| happening with me using 2.6.29-rc2 (your test tree)
| 
Sorry this is not enough information to say whether the result is really
what can be expected. First 
 * where is the 255 returned ? -- is that the return value of getsocktopt()
   or do you mean the value returned in 'ccid'?	
 * what type is 'ccid' ? -- from Documentation/networking/dccp.txt, it 
   should be 'int', not an array of uint8_t;
 * analogous -- what is ccidlen?
 * last - the 'so' argument has to be a connected socket -- I don't know
   whether you tried the getsockopt on a listening socket, where naturally
   the value of the CCID(s) is undefined.
