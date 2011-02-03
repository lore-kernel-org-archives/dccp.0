From: John Heffner <johnwheffner@gmail.com>
Date: Thu, 03 Feb 2011 14:17:14 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <AANLkTinEXYXeZs1=wVQRAPDQ53YY0ne9NgCZN3x1hbaA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, Feb 3, 2011 at 9:00 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
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
> to setup a ns-2 environment but due to lack of time I am a little bit
> behind schedule. Anyway, why not make this a tunable per route knob so th=
at
> it is easier to fix things, e.g. set IW back to 3.


There's already a per-route tunable, right (RTAX_INITCWND)?

  -John
