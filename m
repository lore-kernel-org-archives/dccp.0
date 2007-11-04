From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 04 Nov 2007 17:39:03 +0000
Subject: Re: [PATCH 11/25] Share TFRC sender states via tfrc_ccids
Message-Id: <5640c7e00711040939s532dd136jc8906fbf9f18e260@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312131.03012.leandroal@gmail.com>
In-Reply-To: <200710312131.03012.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/1/07, Leandro <leandroal@gmail.com> wrote:
> [CCID-3/4] Share TFRC sender states via tfrc_ccids
>
> Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
>
Again you should make changes to ccid3.c before it is copied over to
reduce the size of this patch/make more sense

Ian
