From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Nov 2006 15:26:28 +0000
Subject: Re: [RFC] [PATCH]: use explicit enums for CCID 3 states
Message-Id: <200611151526.28575@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611151401.41404@strip-the-willow>
In-Reply-To: <200611151401.41404@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Anyway, there are always tradeoffs, compiler gets more info, but we
|  end up using more memory per socket instance, I guess we can stay like
|  we are now, no? :-)
That is why I sent it as RFC in the first place: it is not broken but would
be good to have. 

I will think about a solution without changing the socket fields,
would BUG be ok instead of the more verbose output? But then, it is not so 
terribly important, it just makes the code harder to understand. 

|  
|  Probably because we stop using a u64 bitfield in the rx case...
Yes it is irksome - could not find anything to put in the 4-bit hole. 

-- Gerrit
