From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 28 Mar 2007 19:17:24 +0000
Subject: Re: [PATCH 1/1][DCCP] getsockopt: Fix DCCP_SOCKOPT_[SEND,RECV]_CSCOV
Message-Id: <5640c7e00703281217m44e742e1l2738eca8bd97cd67@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070328151531.GD20303@ghostprotocols.net>
In-Reply-To: <20070328151531.GD20303@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/29/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> David,
>
>         Please push for 2.6.21 and stable (CCed for good measure).
>
> - Arnaldo
>
> -----------------------------------
>
> We were only checking if there was enough space to put the int, but left len as
> specified by the (malicious) user, sigh, fix it by setting len to sizeof(val) and
> transfering just one int worth of data, the one asked for.
>
> Also check for negative len values.
>
Part of the issue here is possibly that we are using signed ints here
and the type from userspace is socklen_t which by my quick check is
unsigned on my system.

I haven't checked how this is defined on other architectures yet but
if this is the case we should tidyup to remove other possible errors
of this type. I'll look into this some more as time permits.

Or am I talking through a whole in my head?

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
