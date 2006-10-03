From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 03 Oct 2006 19:48:40 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <5640c7e00610031248v1ec6febha3c1bdbab5004d6b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> I disagree with this reading of the RFC.  The RFC explicitly allows the sender
> to calculate X as if every packet had size 's = MSS'.  As usual, the
> implementation can then implement any simplifications such an assumption would
> allow.  An implementation that assumes 's = MSS' can therefore calculate a
> sending rate in packets per second.
>
> Eddie
>
OK. Time for some maths with the TCP throughput equation. I am using
an online version here backed up with testing with my modified DCCP
stack - this matches on runs to within 10% of this equation. The
online equation is here - http://wand.net.nz/~perry/max_download.php -
in the examples below I have changed rtt to 250 ms and loss to 5 %.

In this online calculator the value for s is put into MSS. The reason
for this is we are assuming we are sending maximum size packets which
may not be applicable for DCCP but is for TCP. So we vary the MSS to
reflect s here.

Now starting with a s of 1460 bytes we get a throughput (Xcalc) of
15221 bytes/sec. Now t_ipi is s/X_inst and X_inst on average is X_calc
(it is just adjusted to prevent oscillation). So t_ipi is 96 msecs.

Now change s to 300 bytes we get a Xcalc of 3128 and a t_ipi of 96
msecs. Put in ANY number for s and you will get the same t_ipi of 96
msecs.

This illustrates my point that CCID3 is a packet per second based
congestion control.

Now if we specify the s is 300 to the implementation we get the
desired result, if we average it we get the correct result. However we
can't switch to a packet based equation because if we do the spec says
we should use s=MSS. Lets assume MSS60. Now Xcalc is 15221
bytes/sec. t_ipi is 96 msecs. And we can send the correct rate of
packets.

OK Now working through the example shows that my logic was wrong. I
guess thats what defence of ideas is about - proving it and my idea
was wrong. I apologise for wasting everybody's time!

However this does show an application can't cheat by specifying the
wrong packet size which the spec worries about. Maybe my working
through this helps resolve this a little...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
