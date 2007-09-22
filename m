From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 22 Sep 2007 20:29:29 +0000
Subject: Re: [PATCH 2/5] CCID 4: Clone existing implementation of CCID 3 into ccid4.[ch]
Message-Id: <5640c7e00709221329j6ce1307ehd5c4c9c4b0968e16@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920112321.GA26233@kikai.katei.fi>
In-Reply-To: <20070920112321.GA26233@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/20/07, Tommi Saviranta <wnd@iki.fi> wrote:
> (Yup, it is less than 40 KiB.)
>
>

As discussed previously the CCID4 should share CCID3 code rather than
copy it. This is fine for experimental purposes though - it can't be
merged into mainline kernel as is though. You will need to track
anybody's changes to CCID3 obviously.
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
