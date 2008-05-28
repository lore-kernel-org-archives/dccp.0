From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 28 May 2008 15:56:40 +0000
Subject: Re: Monitoring DCCP: modprobe dccp_probe
Message-Id: <20080528155640.GA17681@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <483D424F.5020307@libero.it>
In-Reply-To: <483D424F.5020307@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| 
| Leandro probably could do it quickly since he already seems to be using
| such a scheme, no?
| 
Sounds like a good idea (and a bit of work) - if Leandro has this
available, it would be good to test.

In Giuseppe's case, I wonder whether it could be due to using a slightly
older kernel (2.6.24). On sparc64 I also had problems with dccp_probe a
while earlier, but now it is loading fine.

Gerrit
