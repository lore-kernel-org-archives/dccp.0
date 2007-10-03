From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 22:18:56 +0000
Subject: Re: [PATCH 13/14]: Initialisation and type-checking of feature sysctls
Message-Id: <5640c7e00710031518m795f056br1034eca4242909e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.56454@strip-the-willow>
In-Reply-To: <200710031502.56454@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Initialisation and type-checking of feature sysctls
>
> The number of feature sysctls is now smaller (it is instead now possible
> to set values on a per-connection basis via sockops); this patch takes care
> of their initialisation and some rudimentary type-checking:
>
>  * Sequence Window uses the specified Wmin2, the maximum is ulong (4 bytes), I have
>    tested and confirmed that it works up to 4294967295 - let's use it for Gbps;
>  * Ack Ratio is between 0 .. 0xFFFF (2-byte unsigned integer);
>  * CCIDs are between 0 .. 255 (FIXME: write handler for available ones);
>  * request_retries, retries1, retries2 also between 0..255 for good measure;
>  * tx_qlen is checked to be non-negative;
>  * sync_ratelimit remains as before.
>
> The sysctls are initialised with the known default values for each feature
> at boot or module load time; for the type-checking the value constraints from
> RFC 4340 have been used. Type checking is important since some of the sysctls
> now directly act on the feature-negotiation process.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
