From: David Miller <davem@davemloft.net>
Date: Sat, 10 Jun 2006 08:31:13 +0000
Subject: Re: [PATCH 1/1] DCCP Ackvec: fix soft lockup in ackvec handling
Message-Id: <20060610.013113.97293100.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20060609182649.GA20777@shorty.sorbonet.org>
In-Reply-To: <20060609182649.GA20777@shorty.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 10 Jun 2006 20:28:39 +1200

> I have tested this and wonder whether it can be pushed upstream for
> Linus for 2.6.17 if at all possible. I know Arnaldo is the maintainer
> but as you are aware he is very busy with other projects at present.

I'll push this upstream over the weekend, it's in my patch
log :-)
