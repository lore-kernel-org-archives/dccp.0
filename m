From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 20 Nov 2008 05:24:56 +0000
Subject: Re: dccp@vger.kernel.org
Message-Id: <20081120052456.GA6227@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <b98e548c0811180955q3c7a5358q798b556c67dbc6d6@mail.gmail.com>
In-Reply-To: <b98e548c0811180955q3c7a5358q798b556c67dbc6d6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Saverio, -
| we have recently submitted to Infocom 2009 a  paper entitled:
| 
| "A Mismatch Controller for Implementing Rate-based Transport Protocols"
| 
| that is definitely  related with your email. You can find the paper at the url:
| http://c3lab.poliba.it/images/0/06/Rmc_ratebased.pdf
| 
| Basically we show that a simple feedback loop can  compensate and
| counteract uncertainty in timers duration due to clock granularity,
| shared Operating System  etc. In this way, the sensitivity to  timer
| granularity is greatly reduced.
Thanks so much for sharing this information. And it is excellent timing --
the algorithm appeared exactly at the right time, when it was needed :)

Maybe you have seen the earlier discussion, the background was that we had
some consensus in this discussion that simply using high-resolution timers
will not improve the situation much for the CCID-3 sending algorithm.

I have had a read through the paper - the rate output graphs look great --
no more of the "wild oscillations" of X_recv that one could observe in CCID-3
test runs.

And I think that it will integrate very well with the goals outlined in
RFC 5348, especially since it defines rather the goals to achieve (a smooth
sending rate) rather than prescribing a specific implementation.

There is no doubt, this calls for implementation. Details may need some
rethinking. I will start at the weekend to tidy up the tree, revising
the interface and remove now obsolete high-resolution timer parts that
would have lead to a much more complicated implementation.

We can then start afresh, with this new algorithm.

Thanks a lot
Gerrit
