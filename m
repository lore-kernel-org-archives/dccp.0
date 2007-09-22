From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 22 Sep 2007 20:37:30 +0000
Subject: Re: [PATCH 4/5] CCID 4: Reduce allowed sending rate by a factor that accounts for packet header size
Message-Id: <5640c7e00709221337r6fefe9cy6e5b0ae2258c866c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920112717.GC26233@kikai.katei.fi>
In-Reply-To: <20070920112717.GC26233@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> + * The header size on data packets is estimated as 36 bytes [RFC XXXX,
> + * Section 5] (floyd-01)
> + */

Reference the Internet Draft here rather than RFC which does not exist.

Otherwise looks fine.
