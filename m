From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 09 Aug 2010 05:59:17 +0000
Subject: Re: Problems with idle DCCP connections
Message-Id: <20100809055917.GA4148@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
In-Reply-To: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| In attempting to set this up I have come across some very odd behavior
| from DCCP. My goal is to open one DCCP connection and then keep it open
| even when the encapsulated protocol is idle (this avoids having a
| three-way handshake for every packet sent). However, in my tests, DCCP
| clamps the sending rate down to three packets per second after a short
| idle period (a few seconds) and then never attempts to increase that
| rate. This seems to be a very unusual and counter-intuitive behavior.
| Has anyone else seen similar behavior? This seems to contradict RFC4341
| section 5.1 which says that CCID2 should slow start after an idle
| period. Is this not implemented yet or is it a bug?
| 
It is probably a bug, the state of the CCID-2 code is not as good as the
CCID-3 code, the latter has received more attention.

But you will find several bug CCID-2 bug fixes already contained in the
DCCP test tree available at
     git://eden-feed.erg.abdn.ac.uk/dccp_exp   [subtree 'dccp' or 'ccid4']
     http://[same-address]

and I would like to ask you to use this tree for testing and bug-fixing, 
since it is ahead of the mainline tree. I know from testing that the 
mainline CCID-2 code does not perform very well.

In addition, there is a CCID-248 ("UDP-like") test-CCID available in the
test tree, which does not perform congestion control. This might be useful
for your tests which need as much bandwidth as possible. 

Please let us know any bugs or problems encountered/fixed.
