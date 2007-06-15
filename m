From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 15 Jun 2007 04:06:27 +0000
Subject: Re: [PATCH 5/5]: Provide central source file and debug facility
Message-Id: <5640c7e00706142106o4563a3d3i91a4318c9f3756de@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706141005.25979@strip-the-willow>
In-Reply-To: <200706141005.25979@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/14/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [TFRC]: Provide central source file and debug facility
>
> This patch changes the tfrc_lib module in the following manner:
>
>  (1) a dedicated tfrc_module source file  (this is later populated
>      with TX/RX hist and LI Database routines);
>  (2) a dedicated tfrc_pr_debug macro with toggle switch `tfrc_debug'.
>
> The first serves to make the source code structure clearer, since module
> initialisation and module parameter statements are currently spread over
> loss_interval.c and packet_history.c (which are part of the tfrc_lib).

Do you intend to get rid of either of these or are we just increasing
number of files?
>
> There is no functional change in this patch: but subsequent patches will
> contribute module initialisation/cleanup routines (left open for now).
>
I'll signoff on it trusting that the changes to come make it worthwhile.

> Point (2) provides a functionality which is available in all other DCCP
> modules already: module debugging is enabled via a Kconfig option, in the
> running code, debugging output can be toggled via the module parameter
> `tfrc_debug'.  So far, one had to resort to dccp_pr_debug for this, but it
> is not a good idea since it destroys the logical module separation and makes
> tfrc_lib debugging dependent on dccp main-module debugging flags.
>
> NB: TFRC debugging is enabled via Kconfig dependency on CCID3 debug,
>     since CCID3 is currently the only `customer' of the TFRC library.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
