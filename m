From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Wed, 21 Nov 2007 18:51:22 +0000
Subject: Re: Test tree patch inventory - update: batch #4
Message-Id: <20071121185122.GJ24995@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Nov 17, 2007 at 03:42:52PM +0000, Gerrit Renker escreveu:
> 
> 11. First batch of CCID2/Ack Vector bug fixes
> ---------------------------------------------
> Most patches in this set are standalone, so again an easy target for cherry-picking. The
> batch is the preparation for the Ack Vector / CCID2 work which is currently in progress.
> 
> 	[ACKVEC]: Reduce length of identifiers

Applied

> 	[CCID2]: Bug in reading Ack Vectors

Applied

> 	[CCID2]: Fix sequence number arithmetic/comparisons


Applied

> 	[CCID2]: Don't assign negative values to Ack Ratio

Applied

> 	[CCID2]: Deadlock and spurious timeouts when Ack Ratio > cwnd


Applied

> 	[CCID2]: Larger initial windows also for CCID2

Applied

> The second set removes several redundant variables and other redundancies.
> It is also a useful candidate for cherry-picking.
> 
> 	[CCID2]: Disable broken Ack Ratio adaptation algorithm

Applied

> 	[CCID2]: Remove unused variable

Applied

> 	[CCID2]: Replace read-only variable with constant

Applied

> 	[CCID2]: Replace cwnd assignment-function with assignment

Applied

> 	[CCID2]: Replace pipe assignment-function with assignment

Applied

> 	[CCID2]: Redundant debugging output

Applied

> 	[CCID2]: Remove redundant synchronisation variable

Applied

> 	[CCID2]: Remove redundant ack-counting variable

Applied

> 	[CCID2]: Remove misleading comment

Applied
