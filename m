From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 29 Apr 2013 03:00:24 +0000
Subject: Re: [RFC][PATCH] tfrc: Correct 2nd Loss Interval Handling
Message-Id: <20130428210024.5582d53e@liptov.cs.ualberta.ca>
List-Id: <dccp.vger.kernel.org>
References: <516C3031.4050405@ohio.edu>
In-Reply-To: <516C3031.4050405@ohio.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Samuel,

> You'll notice that with this fix, the loss event rate option starts increasing (i.e. the loss event
> RATE decreases) after a while. This means that the 2nd loss interval has become large enough to 
> start effecting the loss event rate. In the buggy case, we have to wait until that 2nd loss interval
> is closed by the 2nd loss before it can effect the rate, resulting in the large jump seen above.

many thanks indeed for this excellent work and for taking the time to explain the cause of the problem.
I have applied this to the test tree and will be posting a patch to update CCID-4 (based on your patch)
shortly.

Gerrit
