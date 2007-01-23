From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 23 Jan 2007 21:11:23 +0000
Subject: Re: [PATCHv2 1/7]: Remove build warnings
Message-Id: <5640c7e00701231311vda974fqbeb9d39f0c765f9e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701231540.46450@strip-the-willow>
In-Reply-To: <200701231540.46450@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 24/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Remove build warnings
>
> This
>  1) Clears the following sparc64 build warning:
>     warning: format "%ld" expects type "long int", but argument 3 has type "suseconds_t"
>
>  2) Makes the use of "%llu" consistent for all u64/__u64 datatypes.
>     Thanks to Ian McDonald for this.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
