From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Mon, 11 Dec 2006 02:32:05 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix return value in CCID3
Message-Id: <39e6f6c70612101832l77645985ibe49caac2ae3d629@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612111501.10028.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612111501.10028.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/11/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> In a recent patch we introduced invalid return codes which will result in
> the opposite of what is intended (i.e. send more packets in face of
> peculiar network conditions).
>
> This fixes it by returning ~0 which means not calculated as per
> dccp_li_hist_calc_i_mean.
>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Looks good, applied.

Thanks,

- Arnaldo
