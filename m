From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 03 Feb 2011 22:55:54 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <20110203225554.GA3227@nuttenaction>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

* H.K. Jerry Chu | 2011-02-03 13:17:19 [-0800]:

>> to setup a ns-2 environment but due to lack of time I am a little bit
>> behind schedule. Anyway, why not make this a tunable per route knob so that
>> it is easier to fix things, e.g. set IW back to 3.
>
>You've seemed to get this backwards. Shouldn't we set the default for the normal
>cases and leave the corner cases to the initcwnd and initrwnd knobs to cover?

Yes Jerry, I phrase this a little bit abstruse. Apply David patch and use per
route options to reduce the IW if some curious behavior appear.

It seems the time is come to increase the IW. ;-)

Hagen


