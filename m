From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Jun 2008 08:28:54 +0000
Subject: Re: DCCP and NAT
Message-Id: <20080623082854.GA14592@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <485E62DD.4050405@libero.it>
In-Reply-To: <485E62DD.4050405@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Giuseppe, -
> My ISP (Vodafone Italia) use the NAT, so it's impossible to use dccp  
> protocol in a connection between two host that support DCCP.
> Have you suggestion in order to resolve this problem?
>
Since you are most likely using ISP NAT equipment and since only the
Linux NAT at the moment supports DCCP, the only way around this is
tunnelling. Tom Phelan has written a draft for UDP encapsulation of DCCP
http://www.phelan-4.com/dccp/draft-phelan-dccp-natencap-00.txt
and provides software (DCCP-TP) with support for UDP tunnelling:
http://www.phelan-4.com/dccp-tp/tiki-index.php

Is it possible for you to use Linux NAT instead of the Vodafone NAT?
If yes, we have developed an alternative NAT traversal solution which
does not require tunnelling. Will put information out about this later.

Gerrit
