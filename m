From: David Miller <davem@davemloft.net>
Date: Thu, 12 Apr 2007 21:22:52 +0000
Subject: Re: [PATCH 08/29] Honour initial RTT estimate
Message-Id: <20070412.142252.02275892.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070412211505.GI21292@ghostprotocols.net>
In-Reply-To: <20070412211505.GI21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 18:15:05 -0300

> This is a small optimisation which improves the accuracy of TX
> RTT sampling when an initial RTT sample (e.g. from the intial
> Request/Response exchange) is available.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Ok, even more...

I'm not pulling this stuff in, you guys have to work out a way
to implement this without killing performance on the rest of
the system.

Thanks.
