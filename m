From: Steven Brown <swbrown@variadic.org>
Date: Wed, 05 Mar 2008 19:40:04 +0000
Subject: Existing solutions for encapsulation?
Message-Id: <47CEF714.708@variadic.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I'm running into a need for encapsulation due to various providers 
mangling (mandatory NATs on local EVDO service) or dropping (AT&T Yahoo 
DSL residential service (but business service works it seems)) DCCP 
traffic.  I figure DCCP-NAT[1] support in the stack is exactly what I 
need, but AFAIK it's not implemented yet (only in DCCP-TP I think).

Is there an existing solution at the moment to add the encoding, or near 
term plan to implement it?  If not, would it make sense to route the 
traffic into a tun device that adds/removes the encoding?  Is there a 
better way to get the DCCP packet before it's sent than having an extra 
service/interface like that?  I'm not familiar enough with the kernel 
layer to implement it there in reasonable time which is why I'm looking 
at doing a quick hack in userland.


[1] http://www.phelan-4.com/dccp/draft-phelan-dccp-natencap-00.txt

