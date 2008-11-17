From: David Miller <davem@davemloft.net>
Date: Mon, 17 Nov 2008 06:56:36 +0000
Subject: Re: [PATCH 4/5] dccp: Deprecate Ack Ratio sysctl
Message-Id: <20081116.225636.32402768.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1226751079-15019-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1226751079-15019-5-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:18 +0100

> This patch deprecates the Ack Ratio sysctl, since
>  * Ack Ratio is entirely ignored by CCID-3 and CCID-4,
>  * Ack Ratio currently doesn't work in CCID-2 (i.e. is always set to 1);
>  * even if it would work in CCID-2, there is no point for a user to change it:
>    - Ack Ratio is constrained by cwnd (RFC 4341, 6.1.2),
>    - if Ack Ratio > cwnd, the system resorts to spurious RTO timeouts
>      (since waiting for Acks which will never arrive in this window),
>    - cwnd is not a user-configurable value.
> 
> The only reasonable place for Ack Ratio is to print it for debugging. It is
> planned to do this later on, as part of e.g. dccp_probe.
> 
> With this patch Ack Ratio is now under full control of feature negotiation:
>  * Ack Ratio is resolved as a dependency of the selected CCID;
>  * if the chosen CCID supports it (i.e. CCID = CCID-2), Ack Ratio is set to
>    the default of 2, following RFC 4340, 11.3 - "New connections start with Ack
>    Ratio 2 for both endpoints";
>  * what happens then is part of another patch set, since it concerns the
>    dynamic update of Ack Ratio while the connection is in full flight.
> 
> Thanks to Tomasz Grobelny for discussion leading up to this patch.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
