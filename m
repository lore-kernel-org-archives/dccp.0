From: Julien.HUEBER@fr.thalesgroup.com
Date: Mon, 24 Aug 2009 15:35:36 +0000
Subject: RE: DCCP module insertion issues
Message-Id: <DD7F6BACE0940D4AA451F8762B4D513C025CBDC4@thot.clb.tcfr.thales>
List-Id: <dccp.vger.kernel.org>
References: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
In-Reply-To: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thank you both for your answers.

We are using latest version of Gerrit DCCP test tree pulled from http://eden-feed.erg.abdn.ac.uk/.

We found out that -ESOCKTNOSUPPORT is returned by routine ccid_initialize_builtins in net/dccp/ccid.c if the timer resolution is too low.
Our problem is that whatever the available clocksource used (tsc, acpi_pm, pit or jiffies) we always have an error and the following message in the syslog :

Timer too coarse (999 usec), need 10-usec resolution - check your clocksource

We now have to find out whether it is possible to modify the timer resolution.

Thanks,
Julien.
