From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 28 Sep 2007 18:23:44 +0000
Subject: Re: Iperf CPU usage
Message-Id: <20070928182344.GB23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709281409.23853@strip-the-willow>
In-Reply-To: <200709281409.23853@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Sep 28, 2007 at 02:09:23PM +0100, Gerrit Renker escreveu:
> Earlier on this list there was a thread that the CPU usage of iperf was too high (75%..95%).
> Now, Ingo Molnar has found the problem:
> 
> http://marc.info/?l=linux-kernel&m9088670113210&w=2
> 
> I have tested this and the CPU usage dropped below 10%! 
> 
> Will go and add this patch before the other iperf patches and upload it to 
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#iperf

Yup, Stephen Hemminger also mentioned that a similar patch was already
being merged by the iperf guys, IIRC.

- Arnaldo
