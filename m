From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 03 Sep 2007 23:00:40 +0000
Subject: Re: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <5640c7e00709031600ja174a10s15b3695bbdaeff12@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200708291113.07431.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291113.07431.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I have created a subtree `dccp_fr' which contains all these patches. It can
> be pulled via
>
>         git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp dccp_fr
>
> and, since it is a subtree of the main tree, it automatically inherits
> it (ie. the branches are arranged dccp --> dccp_fr).
>
> Let me know if you are happy with this. I am flexible regarding how to integrate
> the trees (other branch arrangements are possible), but I would like to keep the
> code in separate branches for a while:

Yes I'm happy with this.
>
> * when updating to the forthcoming rev04 of the current rev03 of the Faster Restart
>   draft, one needs to track the old changes and it is difficult to say now what the
>   changes will look like
>
Agree. But don't think this is an obstacle to merging as we are
running obsolete code in other branch/mainline ;-)

> * there are some internal research comments in the code which help tracking rev03,
>   but are specific only to FR implementation
>
Can remove when needed.

> * the CCID3 code is currently facing the following revisions
>         - the current code implements rev00
>         - Tommi's CCID4 relies on rev01 (not sure about Leandro's)
>         - your FR code actually would need rev02
>         - rev02 is in the process of being revised and obsoleted into rev03
>
Agree all the versions are a mess. I think it's worthwhile starting on
upgrading the code base but not a project I'm undertaking at the
moment (or you).

> Hope you are ok with this. If there are other/better suggestions, let me know.
>
Yes absolutely fine.

> Btw: your email client breaks long lines - most of the patches were broken along column 80 or so
>      and needed manual fixing.

Sorry about that. Shifted to a different machine and configured KMail
but missed that one..

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
