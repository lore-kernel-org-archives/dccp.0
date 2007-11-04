From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 04 Nov 2007 01:16:26 +0000
Subject: Re: [PATCH 10/25] Share ccid-3 options enum and struct via tfrc_ccids
Message-Id: <5640c7e00711031816i147774a1q7affb11758ab5eda@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.37882.leandroal@gmail.com>
In-Reply-To: <200710312130.37882.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/1/07, Leandro <leandroal@gmail.com> wrote:
> [CCID-3/4] Share ccid-3 options enum and struct via tfrc_ccids
>
> Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
>
I think the better way to write this patch is to do this to ccid3.c
directly before you copy the code over to ccid4.c - i.e. it should be
earlier in the series and then you won't need to alter ccid4.c

The basic concept is fine though so:
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
