From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Mon, 04 Dec 2006 08:38:18 +0000
Subject: Re: [BUG] CCID3 performance
Message-Id: <20061204083818.GA64094@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
In-Reply-To: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Dec 04, 2006 at 08:34:54AM +0000, Gerrit Renker wrote:
> This is helpful, many thanks. I was using an older 2xP3 Xeon 700Mhz with 2GB Ram and e100
> card. I sometimes think it may be the waiting/sleeping/polling which slows things down, but

I think that SMP and NAPI only add problems.  This is based on rumors.
