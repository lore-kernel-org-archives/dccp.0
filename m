From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Date: Thu, 03 Feb 2011 21:17:19 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <AANLkTimWHAz0SX_u42guHp2KNyQESsH6ysNwRoe7ZVJ=@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, Feb 3, 2011 at 6:00 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
>
> On Wed, 02 Feb 2011 17:07:50 -0800 (PST), David Miller wrote:
>
>> +/* TCP initial congestion window */
>> +#define TCP_INIT_CWND =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A010
>> +
>
> Davem, there is _no_ research how this huge IW will behave in environments
> with a small BDP. Belief it or not, but there are networks out there with=
 a
> BDP similar to ~1980. Why for heaven's sake should this work in these
> environments? There are only _two_ extensive analysis one from Cherry and
> and one from Ilpo. Both analysis focus on current mainstream BDP. I start=
ed

It's more than that. We have also conducted extensive, large scale
experiments covering
all BDP/RTT combinations and the result was documented in details in a
SIGCOMM/CCR paper that can be found from a summary page
http://code.google.com/speed/protocols/tcpm-IW10.html covering all our
IW10 work.

> to setup a ns-2 environment but due to lack of time I am a little bit
> behind schedule. Anyway, why not make this a tunable per route knob so th=
at
> it is easier to fix things, e.g. set IW back to 3.

You've seemed to get this backwards. Shouldn't we set the default for the n=
ormal
cases and leave the corner cases to the initcwnd and initrwnd knobs to cove=
r?

Jerry

>
> HGN
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
