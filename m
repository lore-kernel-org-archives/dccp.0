From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jul 2008 12:04:34 +0000
Subject: Re: DCCP Conformance Test Suite
Message-Id: <20080728120434.GC7589@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <488D3270.1020704@cn.fujitsu.com>
In-Reply-To: <488D3270.1020704@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Download:
| It is available at:
| http://dccpct.sourceforge.net/download.html
| 
| - v6eval with DCCP support:
| http://dccpct.sourceforge.net/v6eval-3.0.14-linux-dccp.tar.gz
| 
| - Test Suite:
| http://dccpct.sourceforge.net/dccp-1.0.0.tar.gz
| 
| Usage:
| http://dccpct.sourceforge.net/usage.html
| 
| Test Report under IPv4:
| http://dccpct.sourceforge.net/log/ipv4/index.html
| 
This is a great piece of work and thank you for making it publicly available.
Such a tool has long been missing and I hope that the word will soon spread and 
that there will be ongoing test effort.

Your work has been valuable help in isolating several hard-to-find bugs
and I very much hope that you will continue to contribute.

Regarding future tests, several things come to mind, where fixing
existing bugs takes precedence.
	  
Here are a few suggestions. I am not sure whether they fit the frame of the
TAHI suite. The underlying idea is to use a traffic monitor and controlled
packet drop to check the behaviour of the stack under loss.

The first use is to test stability of protocol signalling. Maybe you
remember the feature-negotiation bug which only appeared when the Ack
completing the setup handshake was dropped. Leandro observed this bug
when packets were (presumably) dropped due to forking many DCCP
connections in parallel. To trigger this bug between two machines
required a modification of the kernel sources - which was
work-intensive.

The second application is to validate the behaviour of Ack Vectors. This
is however a bit complicated to do: the traffic monitor needs to keep
track of which packets were lost, and check if these sequence numbers
show up in the run-length encoded Ack Vector going back in the reverse
direction. If it would be possible to automate such tests, that would be
awesome, since manually verifying Ack Vectors is a very tedious task to
do. The Ack Vector code needs more work anyway, since on 802.11g I found
that they grow up to half a kilobyte in length, which is too much.

Last, there is ongoing work to add ECN support. For ECN it would be
helpful to look at the behaviour, since ECN router support seems quite
young.

Gerrit
