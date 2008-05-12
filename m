From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 12 May 2008 08:33:54 +0000
Subject: Re: [PATCH 2/2] [RFT] [DCCP]: Policy-based packet dequeueing
Message-Id: <200805121033.55262.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <1210578484-12571-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1210578484-12571-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 12 of May 2008, napisa=B3e=B6:
> From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
>
> This patch adds a generic infrastructure for policy-based dequeueing of
> TX packets and provides two policies:
>  * a simple FIFO policy (which is the default) and
>  * a priority based policy (set via socket options).
> Both policies honour the tx_qlen sysctl for the maximum size of the write
> queue (can be overridden via socket options).
>
> The priority policy uses skb->priority internally to assign an u32 priori=
ty
> identifier, using the same ranking as SO_PRIORITY. The skb->priority field
> is set to 0 when the packet leaves DCCP. The priority is supplied as
> ancillary data using cmsg(3), the patch also provides the requisite parsi=
ng
> routines.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>

I hope that's how you sign off patches (I'm doing it for the first time).
--=20
Regards,
Tomasz Grobelny
