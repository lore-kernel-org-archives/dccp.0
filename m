From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Feb 2008 10:20:59 +0000
Subject: Re: CCID3 over WiFi Study
Message-Id: <20080201102059.GA14424@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080131134138.GA13260@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080131134138.GA13260@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| The killer is the large buffering - do you know what size the Linksys
| has? Also what size transmit buffer and what size sequence validation
| window did you use. If these two were reduced then you might stop the
| buffering occurring elsewhere...
| 
For socket buffer sizes I used the default values (rmem/wmem), the
Sequence Window had been set to 1000 packets on each side (in particular
the long delay very soon lead to Acks becoming apparently out of synch).

Yes, the large buffering needs to be investigated further. Plan to
re-run the tests soon and use different values of the "ip link set
txqueuelen" on the sending host. Incidentally this has 1000 packets,
which agrees with the measured delay.

Couldn't figure out how to set queue sizes in the DD-WRT firmware. Any
hints? Also might be good to compare against original firmware, or use
different routing equipment. Would be great to see other people posting
and/or discussing results.
