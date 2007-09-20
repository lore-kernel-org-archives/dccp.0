From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 22:19:11 +0000
Subject: Re: [PATCH 3/4] CCID4: Signs off patch #2 submitted by Tommi and it organize the copyright and comme
Message-Id: <5bc4c4570709201519p57b3eb97t5812cf1dcf435117@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201054t564cf7aak2cf4cfcd41623c55@mail.gmail.com>
In-Reply-To: <5bc4c4570709201054t564cf7aak2cf4cfcd41623c55@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/20, Tommi Saviranta <wnd@iki.fi>:
> On Thu, Sep 20, 2007 at 14:54:54 -0300, ツ Leandro Sales wrote:
> > + *  This code has been developed by the Federal University of Campina Grande
> > + *  Embedded Systems and Pervasive Computing Lab and University of Helsinki
> > + *  For further information please see
> > + *  http://embedded.ufcg.edu.br/ <leandro@embedded.ufcg.edu.br>
> > + *  http://www.iki.fi/ <wnd@iki.fi>
>
> Looks like I failed to provide Leandro proper information about
> cs.helsinki.fi in time. :-) Anyway, I will have to figure out a proper
> URI for "see also" later, but http://www.iki.fi/ has most definitely
> nothing to do with CCID 4.
>
>
> Signed-off-by: Tommi Saviranta <wnd@iki.fi>
> ---
> diff --git a/net/dccp/ccids/ccid4.c b/net/dccp/ccids/ccid4.c
> index a1c9055..4b8555a 100644
> --- a/net/dccp/ccids/ccid4.c
> +++ b/net/dccp/ccids/ccid4.c
> @@ -1,15 +1,27 @@
>  /*
>   *  net/dccp/ccids/ccid4.c
>   *
> + *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
>   *  Copyright (c) 2007   University of Helsinki, Finland.
>   *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
>   *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
> - *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
>   *
>   *  An implementation of the DCCP protocol
>   *
> + *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
> + *
> + *  This code has been developed by the Federal University of Campina Grande
> + *  Embedded Systems and Pervasive Computing Lab and the Department of Computer
> + *  Science at the University of Helsinki.
> + *  For further information please see
> + *  http://embedded.ufcg.edu.br/ <leandro@embedded.ufcg.edu.br>
> + *  http://www.cs.helsinki.fi/ <wnd@iki.fi>
> + *
> + *  Copyrithg (c) 2005-7 Ian McDonald
> + *
>   *  This code is based on code developed by the University of Waikato WAND
>   *  research group. For further information please see http://www.wand.net.nz/
> + *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
>   *
>   *  This code also uses code from Lulea University, rereleased as GPL by its
>   *  authors:
> diff --git a/net/dccp/ccids/ccid4.h b/net/dccp/ccids/ccid4.h
> index f9ca05b..1b507a6 100644
> --- a/net/dccp/ccids/ccid4.h
> +++ b/net/dccp/ccids/ccid4.h
> @@ -3,12 +3,24 @@
>  /*
>   *  net/dccp/ccids/ccid4.h
>   *
> + *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
>   *  Copyright (c) 2007   University of Helsinki, Finland.
>   *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
>   *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
>   *
>   *  An implementation of the DCCP protocol
>   *
> + *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
> + *
> + *  This code has been developed by the Federal University of Campina Grande
> + *  Embedded Systems and Pervasive Computing Lab and the Department of Computer
> + *  Science at the University of Helsinki.
> + *  For further information please see
> + *  http://embedded.ufcg.edu.br/ <leandro@embedded.ufcg.edu.br>
> + *  http://www.cs.helsinki.fi/ <wnd@iki.fi>
> + *
> + *  Copyrithg (c) 2005-7 Ian McDonald
> + *
>   *  This code is based on code developed by the University of Waikato WAND
>   *  research group. For further information please see http://www.wand.net.nz/
>   *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
>

Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>
