From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 08 Apr 2008 13:38:41 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <20080408133841.GA31174@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> I have a question regarding the original direction - currently it is
>> linked to the client which actively initiates a connection. DCCP  
>> suffers from the problem that peer-to-peer NAT traversal is not
>> really possible just because of this client/server division. There
>> is a proposal which effects a pseudo simultaneous open, by letting
>> the server send an initiation packet, to fix this problem (TCP
>> peer-to-peer NAT traversal also favours simultaneous-open). I wonder
>> if this would be possible, but it is really a future-work question.
>
> Yes, that should be possible. But how does the server know that
> the client intends to initiate a connection?
>
This is outside the actual NAT implementation, via out-of-band, e.g. using SIP
or Session Traversal Utilities for NAT (draft-ietf-behave-rfc3489bis).

In this regard, the role-reversal patch will be a great help, since it
will allow support for peer-to-peer NAT traversal (i.e. NAT-ed server).


The University of Aberdeen is a charity registered in Scotland, No SC013683.

