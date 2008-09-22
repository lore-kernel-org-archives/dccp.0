From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 22 Sep 2008 06:28:07 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080922062807.GA12068@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| There are two paths forward at the current point in time.
| 
| 1) You submit a very small group of patches at a time to me.
|    I'm talking like 5 or 6 patches at a time, maximum.
| 
|    And I'm going to give extra amounts of personal review to
|    these, so it will take even more time than usual.
| 
Further review can never harm, so I am sure this will be good.

I have a question regarding granularity - the current granularity is
meant to be logical, but is low.
It is easy to get distracted by the details since at the end of
the day the 37 patches achieve a rewriting of feat.c in small steps.

Would you therefore be ok with me combining some of the patches or would
you prefer to review the set at its current granularity?

Thanks
Gerrit
