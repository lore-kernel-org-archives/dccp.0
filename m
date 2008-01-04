From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 04 Jan 2008 18:56:52 +0000
Subject: Re: dccp send
Message-Id: <5640c7e00801041056x6a417efew7d5b62cc63e9bbc4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200801020141.16432.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Jan 5, 2008 5:28 AM, Tomasz Grobelny <tomasz@grobelny.oswiecenia.net> wrote:
> Thanks. But while we are at your patch I have one more question: why
> did you choose to implement the algorithm it in ccid3? Shouldn't
> packet priorities and expiration times be processed indepentent of
> ccids? Until now it seemed for me that ccids only control _when_ you
> send data, _what_ you send should be determined by other means. Am I
> missing something here?

This is just for my own private research. If I was proposing this to
be included with the kernel I would agree with you totally.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
