From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 16 Aug 2010 05:19:02 +0000
Subject: Re: Problems with idle DCCP connections
Message-Id: <20100816051902.GC3571@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
In-Reply-To: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Samuel,

thank you very much for testing.

| I do, however, see a bunch of messages like the following
| in /var/log/messages when using CCID-3: "dccp_sane_rtt: RTT sample
| 8644424 out of bounds!"
| 
This message warns that the network has an unusually high RTT (8.64 seconds).

The warning is issued whenever the RTT exceeds 3 seconds, to avoid that the
sending rate of CCID-3 is reduced too much (since X is proportional to s/RTT).

 #define DCCP_SANE_RTT_MAX       (3 * USEC_PER_SEC)

| I will pull the current tree and double check it; however, my problem
| (or at least the symptoms) appears to be fixed without CWV. I'll let you
| know how the new tree works by Monday or Tuesday.
I would be very interested in any performance reports and comments.
