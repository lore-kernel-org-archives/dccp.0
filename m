From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Fri, 23 Jun 2006 08:52:22 +0000
Subject: Re: HOWTO profile CCID2
Message-Id: <20060623085222.GA1719@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <20060622222323.GA2291@shorty.sorbonet.org>
In-Reply-To: <20060622222323.GA2291@shorty.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Jun 23, 2006 at 10:46:19AM +0200, Hagen Paul Pfeifer wrote:
> Did this polling fetch all information - or can it happend that is miss some
> iterations?

It will grab all information.  Check the details section in my last email.
Basically, the overflow bit will tell you whether or not some information got
overwritten causing samples to be lost.  The default behavior of profiler.c is
to complain and exit if an overflow occurs.
