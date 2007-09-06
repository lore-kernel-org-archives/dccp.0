From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:02:47 +0000
Subject: Re: [PATCH 0/10]: Support for passive close
Message-Id: <5640c7e00709052102v733a46acocaaacecc7c51dee5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707121520.48349@strip-the-willow>
In-Reply-To: <200707121520.48349@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/18/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> |  Please note your method works perfectly fine and is an acceptable fix,
> |  and can go in. My method may not even work as I'm thinking out loud
> |  here really.
> This really is appreciated since by looking at the same thing one often gets better ideas,
> please see below.
>
> I am defending my solution on the grounds that I have verified the possible state transitions,
> most signalling is in the kernel, and changes are documented.
>
> The main point behind this patch set is the API: with regard to closing states one now gets
> the same behaviour as with TCP, i.e. the close() calls work as expected - either when called
> directly, or implicitly via exit().
>
OK. I'm (finally) getting back to this and after thinking some more
your solution seems the best.

Will go through patches individually now.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
