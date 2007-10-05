From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 05 Oct 2007 06:23:55 +0000
Subject: Re: [PATCH 12/14]: Implement both feature-local and feature-remote Sequence Window feature
Message-Id: <5640c7e00710042323p7797c9a1m2ddd94545dcfe78a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.54147@strip-the-willow>
In-Reply-To: <200710031502.54147@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Ian -
>
> |  Hmmm.... I had multiple problems when the default window was 100 when
> |  testing in the past - from memory particularly with long RTT, low loss
> |  links. Try putting 100 ms delay on a 100 Mbits/link and see what
> |  happens...
> |
> |  See 7.5.2 of RFC4340:
> <snip>
> |
> |  Or am I missing something again. Maybe you are setting this
> |  automatically and increasing as required? (I haven't gone through and
> |  re-read current source code).
> The above problem is about the question "how do I best set my sequence window". The
> experiences you report are from a Linux stack without feature negotiation for
> Sequence Window, and even without distinguishing feature-local and feature-remote
> sequence window (they were the same).
>
> This patch enables this separation and facilitates communicating the local Sequence
> Window value to the peer. It thus fixes an existing problem.
>
> I am happy to spawn a new thread to separately discuss the issues you are raising,
> but they don't really touch the code - please have another look.
>

OK. I re-read and you're right. I'll have to go read up about feature
negotiation etc.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
