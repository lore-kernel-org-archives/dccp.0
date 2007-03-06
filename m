From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 Mar 2007 09:52:01 +0000
Subject: Re: CCID 3 bounded by OS scheduling granularity
Message-Id: <200703060952.01629@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701221424.36105@strip-the-willow>
In-Reply-To: <200701221424.36105@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > I have performed experiments which confirm that
|  >
|  >  1) when t_ipi < t_gran, the transmit rate is effectively out of control
|  >  2) when t_ipi > t_gran, the actual transmit rate is about a factor of 3
|  >     higher than s/t_ipi would permit.
|  >
|  > http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/packet_scheduling/
|  
|  I've been going over this and wonder if you ever got to the bottom of
|  it by instrumenting it or similar as it doesn't make sense to me....
|  We add t_ipi to t_nom after each packet so even coarse grained
|  scheduling shouldn't do this.
The graphs on that web page are actually the result of instrumenting the kernel.
There are further instrumentation tests, the results of which are on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/impact_of_tx_queue_lenghts/

The problem is not in adding t_ipi, but rather in schedule_timeout which works
at HZ granularity.
