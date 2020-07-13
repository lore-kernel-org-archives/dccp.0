From: David Miller <davem@davemloft.net>
Date: Mon, 13 Jul 2020 18:55:01 +0000
Subject: Re: [PATCH] [DCCP]: Replace HTTP links with HTTPS ones
Message-Id: <20200713.115501.208223024761834676.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20200713075108.32143-1-grandmaster@al2klimov.de>
In-Reply-To: <20200713075108.32143-1-grandmaster@al2klimov.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Alexander A. Klimov" <grandmaster@al2klimov.de>
Date: Mon, 13 Jul 2020 09:51:08 +0200

> Rationale:
> Reduces attack surface on kernel devs opening the links for MITM
> as HTTPS traffic is much harder to manipulate.
> 
> Deterministic algorithm:
> For each file:
>   If not .svg:
>     For each line:
>       If doesn't contain `\bxmlns\b`:
>         For each link, `\bhttp://[^# \t\r\n]*(?:\w|/)`:
> 	  If neither `\bgnu\.org/license`, nor `\bmozilla\.org/MPL\b`:
>             If both the HTTP and HTTPS versions
>             return 200 OK and serve the same content:
>               Replace HTTP with HTTPS.
> 
> Signed-off-by: Alexander A. Klimov <grandmaster@al2klimov.de>

Git will remove everything inside of [] brackets, so "[DCCP]" is
not appropriate.

I changed it to use "dccp: " which is consistent with other recent
changes to this code when I applied your patch.

Thank you.
