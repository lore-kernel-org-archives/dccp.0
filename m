From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 05 Dec 2006 20:42:18 +0000
Subject: Re: [PATCH 1/7]: Check against too large p
Message-Id: <5640c7e00612051242v516cad01ybd1f17f47a0e0f04@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/6/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Check against too large p
>
> This patch follows a suggestion by Ian McDonald and ensures that in
> the current code the value of p can not exceed 100%.  Such a value is
> illegal and would consequently cause a bug condition in tfrc_calc_x().
>
> The receiver case is also tested, and a warning message is added.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
