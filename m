From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 05 Oct 2007 06:54:37 +0000
Subject: Re: [PATCH 4/5]: Minisock unemployed
Message-Id: <5640c7e00710042354s76b14107x7b2dd98a3cd1248b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710041501.59708@strip-the-willow>
In-Reply-To: <200710041501.59708@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Minisock unemployed
>
> This patch removes one unused field (Ack Ratio) from the minisock structure.
> After this removal, only one field - the Boolean flag for enabling NDP count - remains.
> So once this is put into dccp_sock as well, minisock becomes empty.
>
> The reason is that all state-passing is now dynamic, through the use of feature
> negotiation. The activation of features takes place at the end of the initial
> handshake (with the exception of client sequence window, which uses the default of 100
> until the handshake completes). The sysctls now seed the initial feature values and can
> optionally be overridden on a per-connection basis using sockopts (as for example in the
> CCID-sockopt patches).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
