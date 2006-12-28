From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 28 Dec 2006 04:48:10 +0000
Subject: Re: [PATCH 5/8]: Move debugging macro to header file
Message-Id: <5640c7e00612272048t10efc653ocf2e7f83881d9096@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
In-Reply-To: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> You are right, I have tested this. Given that this patch is of no use then,
> I would like to retract it (it is no longer online).
> With regard to the short-term solution: at some point of time, say middle
> January ... begin February, I would like to toss out all unnecessary debugging
> statements in ccid3 - the amount of debugging output at the moment is enormous
> and overwhelming.
>
I'm finding the amount of debugging output great but understand where
you are coming from...

I'm happy to get them removed once we fix up a few more issues. If
people want it removed sooner I can always put the debugging in my own
tree.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
