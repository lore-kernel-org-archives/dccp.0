From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 27 Jul 2007 04:53:51 +0000
Subject: Re: [PATCH 3/5]: Wrong format in printk
Message-Id: <5640c7e00707262153g4057c9b6xc225216cd90386e1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.44426@strip-the-willow>
In-Reply-To: <200707261356.44426@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/27/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Wrong format in printk
>
> The elapsed time uses u32, but printk was using %d, not %u.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
