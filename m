From: Bruce Barnett <dccp@grymoire.com>
Date: Tue, 20 Dec 2005 17:38:16 +0000
Subject: Re: Discussion of ECN API?
Message-Id: <200512201738.jBKHcGm15341@observ.crd.ge.COM>
List-Id: <dccp.vger.kernel.org>
References: <200512192127.jBJLRou27403@observ.crd.ge.COM>
In-Reply-To: <200512192127.jBJLRou27403@observ.crd.ge.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


> I'm not aware of any, at the same time I think DCCP should at least
> expose the info on ack vectors,so the question is: is the information
> available on ack vectors enough for you (the app writers?)?


Raw information may be harder to deal with, but at least all of the
information is there.  After we have a better idea on the algorithms
needed for intelligent applications, we can provide a friendlier
interface. I don't think we know the best algorithms yet.

I think DCCP-enabled applications that are aware of congestion are key
to the next generation of streaming networking.  TCP-based applications
don't care if the network is congested. Either the data arrives or it
doesn't. but VoIP/DCCP applications need to deal with latency and
reliability, and if quality drops, they must take responsibility.

Consider a VoIP application with a 10% packet loss.  With some
vocoders, a 10% loss is unintelligable. So the application is sending
out 90% of the packets with zero effectiveness.  Those packets are
useless, yet they are contributing to the congestion.  I view this as
abuse to the network in two ways (1) sending out packets that are
contributing to congestion, and (2) doing so in such a way that the
packets are useless once they arrive. TCP doesn't abuse the 
network like this.

Likewise, if the reliability was high, but the latency increased to 2
seconds per packet, then the usefullness of the bandwidth also
decreases as the mouth-to-ear delay increases.

Application adaption is key to minimizing network abuse for
streaming applications like VoIP.


Now we just have to figure out how to do it the right way. :-)
