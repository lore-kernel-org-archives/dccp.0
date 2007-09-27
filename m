From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 27 Sep 2007 19:38:07 +0000
Subject: Re: [PATCH 1/11]: Remove unused and redundant validation functions
Message-Id: <5640c7e00709271238i54769e44m7ddeab2e19e8a5ae@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709271520.41173@strip-the-willow>
In-Reply-To: <200709271520.41173@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Remove unused and redundant validation functions
>
> This removes two inlines which were both called in a single function only:
>
>  1) dccp_feat_change() is always called with either DCCPO_CHANGE_L or DCCPO_CHANGE_R as argument
>     * from dccp_set_socktopt_change() via do_dccp_setsockopt() with DCCP_SOCKOPT_CHANGE_R/L
>     * from __dccp_feat_init() via dccp_feat_init() also with DCCP_SOCKOPT_CHANGE_R/L.
>
>     Hence the dccp_feat_is_valid_type() is completely unnecessary and always returns true.
>
>  2) Due to (1), the length test reduces to 'len >= 4', which in turn makes
>     dccp_feat_is_valid_length() unnecessary.
>
> Furthermore, the inline function dccp_feat_is_reserved() was unfolded,
> since only called in a single place.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
