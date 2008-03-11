From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 11 Mar 2008 12:45:28 +0000
Subject: Re: dccp bugs (Was: Re: panic on 2.6.24rc5)
Message-Id: <20080311124528.GA15352@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Tomasz,

after quite some testing and calculations, my understanding of the
strange behaviour of CCID-3 over loopback is that it is due to the
combination of
 * an application-limited sender (ie. sending rate X_send < s/RTT);
 * very low RTT as compared to inter-packet gap;
 * frequent expiry of the nofeedback timer;
 * the particular interpretation of "idle periods" in rfc3448bis-00.

Hence as you pointed out, the Token Bucket Filter solution will indeed
not cure the problem. Artificially inflating the link RTT, on the other
hand, causes the computation of X to stabilise towards s/RTT.	

I have written up the causes etc. on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/ccid3_over_loopback/

This was not easy to do and so I appreciate comments if there are any
errors or misinterpretations.

Gerrit

Quoting Tomasz Grobelny:
| Dnia Monday 10 of March 2008, Gerrit Renker napisa?:
| > Now I have a question: adding 1 ms delay at the interface avoided the
| > hang-up, but what do you mean by "long enough"? Is this 60 seconds?
| >
| I tested it for something like 100 seconds and didn't encounter any problems.
| 
| > But since the average RTT is 48 microseconds in the `outfile', I am
| > assuming that the outfile was produced when the delay was not added to
| > the interface?
| >
| Yes, that's what I thought you asked me for...
| 
| > There is a long-standing problem (at least 1 year) with regard to CCID-3
| > over high-speed networks (and lo interface is in fact a high-speed
| > interface): high link speeds are outside the control region of CCID-3.
| >
| > The peak limit of controllable speed is about 12 Mbps. Everything higher
| > that will cause problems. I have not tested, but you may be able to
| > also silence this behaviour by using a netem token-bucket filter with
| > e.g. a maximum bitrate of <= 10 Mbps.
| >
| I somehow doubt it because setting up tbf with limit greater than the actual 
| traffic should have no influence at all. But let's check it...
| sudo tc qdisc add dev lo root handle 1:0 tbf rate 30kbit burst 30kbit latency 
| 500ms
| 
| Still the speed drops down to 1 packet per 64 seconds.
| 
| > So I think the least thing we need to do is put a warning into the DCCP
| > Wiki that people should add interface delay when using CCID-3 for
| > testing over loopback.
| Maybe CCID-3 could somehow disable itself when it detects it is not necessary?
| -- 
| Regards,
| Tomasz Grobelny
| 
| 

-- 
