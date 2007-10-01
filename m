From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 20:07:24 +0000
Subject: Re: [PATCH 3/3]: Convert Reset code into socket error number
Message-Id: <5640c7e00710011307t5da80e35w5ca313232614c791@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709291744.53552@strip-the-willow>
In-Reply-To: <200709291744.53552@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> He used a "designated initializer", i.e. he said at which index in the
> array it the value is to be set. So it really doesn't matter the order.
> And when checking if the code was within the valid range he tested
> against the last entry in the enum. Correct code. :-)
>
> - Arnaldo
>
Yes you are correct. I misread the code.

However - I'd prefer another constant to match last in enum at the
same point as the declaration of the enum. This way if values are
added other code doesn't break. I've seen this done before quite a few
times. It is dangerous on relying on the last value when it's not
explicitly marked as the last value.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
