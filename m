From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 22:29:03 +0000
Subject: Re: [PATCH 3/11]: Upgrade NDP count from u32 to u64
Message-Id: <5640c7e00710011529p48c8b583o7d6abada70302ed0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.16688@strip-the-willow>
In-Reply-To: <200710011518.16688@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Upgrade NDP count from u32 to u64
>
> This upgrades the data type and part of the processing code for the NDP count
> option from 4 to 6 bytes, since the option can be up to 6 bytes (RFC 4340).
>
> The data type is 8 bytes, but the actual limit is enforced by the maximum
> of dccp_bytes_per_value(), which is 6.
>
> I didn't update the full CCID3 code, though; but inserted overflow warnings which
> will raise alarms when NDP counts greater than 2^32-1 appear. The reason is that
> the code has been thoroughly tested with an u32 NDP, and changing to u64 will have
> many subtle consequences: there are for instance many comparisons between signed
> integer and u64, getting one of these wrong will twist the outcome. So, I'd prefer
> to wait for the warnings first and do a separate patch later if CCID3 really runs
> into that limit.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
