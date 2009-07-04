From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 04 Jul 2009 18:45:36 +0000
Subject: Re: [Bugme-new] [Bug 13692] New: dccp_ipv4 has >1 usage count and
Message-Id: <20090704184536.GA6233@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| 
| Well, I tried "rmmod -f" first thing after noticing this behavior
| and got a kernel crash dump immediately.
| 
| I'm not near that machine currently, but I'll post the crash dump on
| Monday.
| 
What is most important to know: did you do the "rmmod -f" while any
sockets were active? Did you have DCCP traffic going on before (not
assuming while) this happened?
(It is possible to see the current socket state using "ss -dane".)
