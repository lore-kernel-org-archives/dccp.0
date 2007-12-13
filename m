From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 13 Dec 2007 16:35:57 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <5640c7e00712130835y2f818df5qf5bf9220db489a58@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Burak
>
> I have tried to replay your results but can not find anything wrong with the current test kernel.
> Please have a look at the results below, I repeated the same experiment on two different testbeds.
>
Coming in very late in this thread I'd just make a couple of observations:
- I'm still using 2.6.20 for myself but only because for my PhD I need
one baseline and if I were to upgrade I'd have to rerun every single
test for my PhD. A daunting task. I would recommend anyone else use
more modern code. In particular the 2.6.20 code often crashes when
running at full speed and also is missing a whole lot of
fixes/improvements
- I know for a while there were issues like Burak experienced but I
have no idea if there still is. It might be as Gerrit says because he
is not using latest code which has now been explained
- when I did have issues like Burak I tracked it down to the send
credit side of things. I could never quite prove exactly what was
going on though. If problems are still there that is where I would
look first
- I don't have time to really help :-( Burak - if you want to help
hack DCCP code as well that would be awesome.

Ian
