From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 21 Aug 2009 20:51:11 +0000
Subject: Re: DCCP module insertion issues
Message-Id: <20090821205111.GA5589@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
In-Reply-To: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > insmod: error inserting 'dccp.ko' : -1 Socket type not supported
|  
| We saw on the mailing list that this error can be caused by the timer
| resolution (on the post "dccp ccid3 : Runtime verification of timer
| resolution"). Our clocksource was "tsc", but even when changing it to
| "acpi_pm" (which is working just fine with DCCP on another machine) we are
| still getting this error.
There is an easy way to see whether the problem is caused by the timer: can
you check the syslog (/var/log/messages) for a message like

 kernel: Timer too coarse \d+ usec, need 10-usec resolution - check your clocksource

If yes, then it can be resolved via the timer resolution, if not, then the cause
is a different problem - such as explained by Arnaldo.

Should it be a timer problem, you should still be able to load dccp_ccid2
since the high-resolution timers are only needed by CCID-3.

Can you please verify if you see such a message in your logs?

| Moreover, DCCP used to work on this machine when an older version
| (2.6.26-rc8) of the modified Kernel was installed.
That is over a year ago, quite a few things have changed.
