From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:54:45 +0000
Subject: Re: [PATCH 10/10]: Collapse repeated `len' statements into one
Message-Id: <5640c7e00709052154t10778b07x7526c30c4d948c7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Collapse repeated `len' statements into one
>
> This replaces 4 individual assignments for `len' with a single
> one, placed where the control flow of those 4 leads to.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
