From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 15 Jun 2007 04:02:41 +0000
Subject: Re: [PATCH 3/5]: Move NULL-protection into function
Message-Id: <5640c7e00706142102i6cac2ad5y6b247335a64558dc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706141005.20094@strip-the-willow>
In-Reply-To: <200706141005.20094@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/14/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Move NULL-protection into function
>
> This moves 10 instances of testing against NULL into the function which is
> used to de-reference the CCID-private data.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

This is another one that can go directly into Arnaldo's tree on it's own.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
