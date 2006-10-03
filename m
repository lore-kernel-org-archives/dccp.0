From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Tue, 03 Oct 2006 18:18:15 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <4522A967.8010506@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> As I read RFC4342 I can't implement a packets per second
> implementation directly - there are several options but packets per
> second is not one of them. The mathematical equation allows it as you
> seem to agree by your first statement. The RFC doesn't. If we track
> the average packet size it works but then that is a whole lot more
> complex code to achieve exactly the same thing.

I disagree with this reading of the RFC.  The RFC explicitly allows the sender 
to calculate X as if every packet had size 's = MSS'.  As usual, the 
implementation can then implement any simplifications such an assumption would 
allow.  An implementation that assumes 's = MSS' can therefore calculate a 
sending rate in packets per second.

Eddie
