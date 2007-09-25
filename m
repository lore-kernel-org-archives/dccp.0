From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 25 Sep 2007 14:40:26 +0000
Subject: Re: [PATCH 1/8]: Add FIXME for send_delayed_ack
Message-Id: <20070925144026.GF18348@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709251529.52965@strip-the-willow>
In-Reply-To: <200709251529.52965@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Sep 25, 2007 at 03:29:52PM +0100, Gerrit Renker escreveu:
> [DCCP]: Add FIXME for send_delayed_ack
> 
> This adds a FIXME to signal that the function dccp_send_delayed_ack is nowhere
> used in the entire DCCP/CCID code.
> 
> Using a delayed Ack timer is suggested in 11.3 of RFC 4340, but it has also
> rather subtle implications for the Ack-Ratio-accounting.
> 
> CCID2 does not use this (maybe it should).
> 
> I think leaving the function in is good, in case someone wants to implement
> this.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Well spotted, I just checked and it really was never used!

applying

- Arnaldo
