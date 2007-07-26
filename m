From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 26 Jul 2007 10:02:27 +0000
Subject: Re: TFRC Faster Restart implementation for Linux DCCP
Message-Id: <200707261102.27871@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
In-Reply-To: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > There is an issue with the ping probes, will write up in a separate email.
|  >
|  I'm not intending to implement ping probes as per IETF mailing list.
I am just about to catch up with the results from Monday ... it seems the authors
are going to make the ping probes optional anyway.
http://www1.ietf.org/mail-archive/web/dccp/current/msg02478.html

The problem that I found with the ping probes is that they need to be sent at a
rate of max(t_ipi, 4*R). With small RTTs, this would mean bursts of 3..10 ping
packets per timer tick ... which is quite a lot for an `idle' connection.
