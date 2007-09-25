From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 22:50:38 +0000
Subject: Re: [PATCH 2/8]: Add Support for Data 1 .. 3 fields of Reset packets
Message-Id: <5640c7e00709251550jf730d04ie9f50fccb84f4e36@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709251529.56581@strip-the-willow>
In-Reply-To: <200709251529.56581@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/26/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Add Support for Data 1 .. 3 fields of Reset packets
>
> This adds fields to support the informational Data 1..3 fields of the
> DCCP-Reset packets (RFC 4340, 5.6), and makes minor cosmetic changes
> to documentation.
> Code which fills in these fields follows in subsequent patches, it is
> primarily used for reporting option-processing and feature-negotiation
> errors.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
