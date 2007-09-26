From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 26 Sep 2007 08:44:00 +0000
Subject: Re: [PATCH 1/8]: Add FIXME for send_delayed_ack
Message-Id: <200709260944.00380@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709251529.52965@strip-the-willow>
In-Reply-To: <200709251529.52965@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian -
|  How about using #if 0, #endif around it to keep the code in the tree
|  but not compiled.
|  
|  This is done a fair bit elsewhere and if never used it gets removed.
this is a good idea actually, the problem that I have with this is it makes the 
code look unfinished and hackish, but this is a self-contained function which I 
think would serve its purpose - it is just not used at the moment.

I was considering taking this on board, but noted that Arnaldo had applied this
already. And I think that keeping delayed Acks an option might be useful for CCID2.
 
