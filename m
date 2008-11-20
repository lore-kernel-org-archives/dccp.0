From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 20 Nov 2008 06:24:08 +0000
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Message-Id: <20081120062408.GD6227@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks Ian for the comments and suggestions, which is input for further
work. Hope to start this poco a poco soon.

| > Do you think we could live with clamping the RTT to some sensible
| > minimum, since on a local LAN the use of congestion control is
| > questionable? I was thinking in the order of 0.5 ... 1msec.
| >
| I think that is a good idea - if 1 msec, and HZ = 1000 then we
| wouldn't lose any transmission capability.
| 
Probably it will require a bit of testing, it might be that some
fine-tuning is needed since a lower RTT also means a lower maximum
throughput -- but maybe that limit is fully sufficient for the target
operational range of CCID-3 (streaming, not bulk data transfer).

Gerrit
