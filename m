From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 11 Mar 2008 02:31:10 +0000
Subject: Re: dccp bugs (Was: Re: panic on 2.6.24rc5)
Message-Id: <5640c7e00803101931h3286bfa7k72c56cf340a2b854@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2008/3/11 Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>:
> Maybe CCID-3 could somehow disable itself when it detects it is not necessary?

That is an issue for the protocol designers, not the implementers...

I have had discussions around whether CCID3 is stable or not at high
speeds. I tend to think that it is and that we have a couple of bugs
lurking around. I got about 75% of the way through proving this but I
ran out of time.... So feel free to dive into kernel code.

Please note that I said 75% - my thoughts might be totally wrong as
didn't quite get to the bottom of it. If you go back about six months
to a year in the archives you might discover the discussion beteen
Gerrit and myself.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
