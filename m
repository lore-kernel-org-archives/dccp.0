From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 22:55:56 +0000
Subject: Re: [PATCH 4/8]: Factor out common code for generating Resets
Message-Id: <5640c7e00709251555n2e00fd29qbcb2886665d3ac4f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.38041@strip-the-willow>
In-Reply-To: <200709251530.38041@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/26/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Factor out common code for generating Resets
>
> This factors code common to dccp_v{4,6}_ctl_send_reset into a separate function,
> and adds support for filling in the Data 1 ... Data 3 fields from RFC 4340, 5.6.
>
> It is useful to have this separate, since the following Reset codes will always
> be generated from the control socket rather than via dccp_send_reset:
>  * Code 3, "No Connection", cf. 8.3.1;
>  * Code 4, "Packet Error" (identification for Data 1 added);
>  * Code 5, "Option Error" (identification for Data 1..3 added, will be used later);
>  * Code 6, "Mandatory Error" (same as Option Error);
>  * Code 7, "Connection Refused" (what on Earth is the difference to "No Connection"?);
>  * Code 8, "Bad Service Code";
>  * Code 9, "Too Busy";
>  * Code 10, "Bad Init Cookie" (not used).
>
> Code 0 is not recommended by the RFC, the following codes would be used in
> dccp_send_reset() instead, since they all relate to an established DCCP connection:
>  * Code 1, "Closed";
>  * Code 2, "Aborted";
>  * Code 11, "Aggression Penalty" (12.3).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
