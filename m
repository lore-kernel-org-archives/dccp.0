From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 26 Jul 2007 23:16:28 +0000
Subject: Re: [PATCH][dccp] Fix memory leak and clean up style - dccp_feat_empty_confirm()
Message-Id: <5640c7e00707261616x8eb332fg2406b72d2e1f1f12@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707270039.37860.jesper.juhl@gmail.com>
In-Reply-To: <200707270039.37860.jesper.juhl@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/27/07, Jesper Juhl <jesper.juhl@gmail.com> wrote:
>
> Greetings,
>
> There's a memory leak in net/dccp/feat.c::dccp_feat_empty_confirm().
> If we hit the 'default:' case of the 'switch' statement, then we
> return without freeing 'opt', thus leaking 'struct dccp_opt_pend'
> bytes.
> The leak is fixed easily enough by adding a kfree(opt); before the
> return statement.
> The patch also changes the layout of the 'switch' to be more in line
> with CodingStyle.
>
> Patch has been compile tested.
>
> Please consider merging.
>
>
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
