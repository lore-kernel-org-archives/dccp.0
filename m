From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 28 Nov 2007 13:19:12 +0000
Subject: Re: [PATCH 1/4]: Use AF-independent rebuild_header routine
Message-Id: <20071128131911.GA25255@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11962389111717-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11962389111717-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Nov 28, 2007 at 08:35:08AM +0000, Gerrit Renker escreveu:
> [DCCP]: Use AF-independent rebuild_header routine
> 
> This fixes a nasty bug: dccp_send_reset() is called by both DCCPv4 and DCCPv6, but uses
> inet_sk_rebuild_header() in each case. This leads to unpredictable and weird behaviour:
> under some conditions, DCCPv6 Resets were sent, in other not.
> 
> The fix is to use the AF-independent rebuild_header routine.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Thanks, applied.

- Arnaldo
