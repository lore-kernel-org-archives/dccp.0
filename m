From: Samuel Jero <sj323707@ohio.edu>
Date: Fri, 30 Jul 2010 21:07:10 +0000
Subject: Problems with idle DCCP connections
Message-Id: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello All,

I am a researcher at Ohio University looking to encapsulate a special
point-to-point Delay Tolerant Networking protocol in DCCP instead of UDP
to take advantage of DCCP's congestion control.

In attempting to set this up I have come across some very odd behavior
from DCCP. My goal is to open one DCCP connection and then keep it open
even when the encapsulated protocol is idle (this avoids having a
three-way handshake for every packet sent). However, in my tests, DCCP
clamps the sending rate down to three packets per second after a short
idle period (a few seconds) and then never attempts to increase that
rate. This seems to be a very unusual and counter-intuitive behavior.
Has anyone else seen similar behavior? This seems to contradict RFC4341
section 5.1 which says that CCID2 should slow start after an idle
period. Is this not implemented yet or is it a bug?

My test machines are running Ubuntu 10.04. Uname -a
"2.6.32-24-generic-pae #38-Ubuntu SMP Mon Jul 5 10:54:21 UTC 2010 i686
GNU/Linux". I have seen identical behavior with Ubuntu 9.10 (Linux
2.6.31). I'm using CCID2 "TCP-like Congestion control" since I want as
much bandwidth as possible, even if that means rapid fluctuations.

Thanks.

Sincerely,
Samuel Jero

