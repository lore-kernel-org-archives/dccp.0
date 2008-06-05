From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 05 Jun 2008 20:27:17 +0000
Subject: Re: [dccp] [RFC/RFT] [Patch 1/2]: Allow to distinguish original
Message-Id: <20080605202716.GA6823@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080605144529.GB8800@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080605144529.GB8800@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Jun 05, 2008 at 03:45:29PM +0100, Gerrit Renker escreveu:
> dccp: Allow to distinguish original and retransmitted packets

Why not do it the way I suggested? I.e. using
__dccp_transmit_skb/dccp_transmit_skb? Less changes, same effect, or am
I missing something?

- Arnaldo
