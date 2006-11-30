From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Nov 2006 18:11:50 +0000
Subject: Re: [DCCP]: Fix BUG in send time calculation
Message-Id: <200611301811.50577@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611301541.36467@strip-the-willow>
In-Reply-To: <200611301541.36467@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Arnaldo,

|  > I will do more tests tomorrow and see how it behaves.
|  
|  Thanks for testing, I'm going to apply both now,
That would be really great. I have done some testing - the bug is fixed by the second patch.
However, the throughput is much higher when using a RTO timeout of 1 second (as per configuration menu),
via the first patch - so it does seem to be useful (and different settings can be tested).

I'd be grateful for any further CCID 3 observations - hopefully we can get it up to speed soon.

Gerrit
