From: David Miller <davem@davemloft.net>
Date: Wed, 26 Sep 2007 05:40:21 +0000
Subject: Re: [PATCH 2/6] [DCCP]: Provide 10s of microsecond timesource
Message-Id: <20070925.224021.56796161.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070922210937.GG4887@ghostprotocols.net>
In-Reply-To: <20070922210937.GG4887@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 18:09:37 -0300

> This provides a timesource, conveniently used for DCCP timestamps, which
> returns the elapsed time in 10s of microseconds since initialisation.
> This makes for a wrap-around time of about 11.9 hours, which should be
> sufficient for most applications.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied.

