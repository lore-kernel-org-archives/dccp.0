From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Mon, 24 Sep 2007 21:35:11 +0000
Subject: Re: Towards the ccid-3 and ccid-4 integration
Message-Id: <5bc4c4570709241435n5bba43bcje1997bff14605ad9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
In-Reply-To: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/24, ツ Leandro Sales <leandroal@gmail.com>:
> Hi list,
>   I'm currently trying to define the steps in order to get a good
> patchset for the initial ccid-4 implementation. Thus, I'd like to
> discuss with all of you some topics and procedures:
>
> - Rewrite all the patches (from me and Tommi) and resubmit to Gerrit
> as a unique patchset, as suggested by Ian. Besides, ask Gerrit to
> overwrite the current ccid4 branch;
> - Identify and provide common code between ccid-4 and ccid-3.
>   1 - minor functions from ccid-3.c to ccid-3.h and include it (.h) in
> the ccid-4.c, as suggested by Ian and Arnaldo
>   2 - for more complex functions, write a dccp_ccid3_lib.ko, as
> suggested by arnaldo
>
> Please, let me know if I've forgot something.
>
> Leandro.
>

Is there someone that would like to comment the proceeds that me and
Tommi will adopt for the initial ccid-4. Tommi, anything more?

Leandro.
