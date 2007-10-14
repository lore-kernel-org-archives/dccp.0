From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 14 Oct 2007 00:20:27 +0000
Subject: Re: [PATCH 3/5]: Introducing CCMPS
Message-Id: <5640c7e00710131720g11c1ddcdub5700cd27b355759@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710121051.54901@strip-the-willow>
In-Reply-To: <200710121051.54901@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Introducing CCMPS
>
> This introduces a CCMPS field for setting a CCID-specific upper bound on the application payload
> size, as is defined in RFC 4340, section 14.
>
> Only the TX CCID is considered in setting this limit, since the RX CCID generates comparatively
> small (DCCP-Ack) feedback packets. The CCMPS field includes network and transport layer header
> lengths. The only current CCMPS customer is CCID4 (via RFC 4828).
>
> A wrapper is used to allow querying the CCMPS even at times where the CCID modules may not have
> been fully negotiated yet.
>
> In dccp_sync_mss() the variable `mss_now' has been renamed into `cur_mps', to reflect that we are
> dealing with an MPS, but not an MSS.
> Since the DCCP code closely follows the TCP code, the identifiers `dccp_sync_mss' and
> `dccps_mss_cache' have been kept, as they have direct TCP counterparts.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
