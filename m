From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 15 Apr 2007 15:56:44 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <200704151656.44957@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  It's not totally pointless Dave because it is a rate based protocol
|  not a window based protocol and you've got the real issue of slow
|  receivers especially when we use a whole lot of CPU... It's not
|  network congestion but still should be dealt with. There's probably
|  other scenarios too - e.g. I can think of a 10 Mbit radio link between
|  two buildings that run on 100 Mbit internally. TCP works fine as no
|  acks will stop transmission but a rate based one will keep on
|  trying.... Although this isn't a local switch as you mention but it is
|  low RTT.
I think that we can use quite a lot of that input, but it requires some
thinking - which IMO is what you are trying to say here. And agrees with
what I am trying to say - we need some revision so that we don't end up
coding RFC 3448 blindly.


|  Eddie - I would like to work on this more in answer to your question.
|  I'll see what I can do over the next weeks once I get a paper out of
|  the way (or when I get bored with it!). Gerrit's work is nearly there.
|  What I'd like to do is work on this whole granularity/out of control
|  thing he keeps referring to. I am not convinced but I need to put up
|  or shut up by replicating some of his work and fixing the bugs or
|  admitting I'm wrong.
I think it is less a question of wrong/not wrong but rather "works/doesn't work".

Since the patches (apart from one minor improvement) do not touch the packet
scheduling engine in net/dccp/output.c, can I suggest to work through the submitted
set of patches first? They fix other problems and I think that they make CCID3
quite a bit more lightweight. This would simplify working on that problem, too. Ok?
