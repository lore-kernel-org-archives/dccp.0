From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 09 Jan 2008 14:17:19 +0000
Subject: Re: FW:  ccid2/ccid3 oopses
Message-Id: <20080109141719.GA10175@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <93680347@web.de>
In-Reply-To: <93680347@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > >> the easiest way to reproduce is:
| > >> 
| > >> while true;do modprobe dccp_ccid2/3;modprobe -r dccp_ccid2/3;done
| > >> after short time, the kernel oopses (messages below)
| > >> 
<snip>
| 
| Gerrit, the control socket isn't attached to any CCID module, so the
| CCID modules should be safe to remove, and IIRC they were safe to
| unload.
| 
Ah, right. I have misread the email. And can confirm the above: running
the for-loop at the top of the message (60 seconds uninterrupted for
CCID2,3 each) brought no oopses.
So maybe the cause triggering this oops is somewhere else.
