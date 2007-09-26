From: Tommi Saviranta <wnd@iki.fi>
Date: Wed, 26 Sep 2007 13:22:02 +0000
Subject: Re: unchanged functions between ccid-3 and ccid-4
Message-Id: <20070926132202.GA4344@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201928l270b24cdod359349ca3d3508@mail.gmail.com>
In-Reply-To: <5bc4c4570709201928l270b24cdod359349ca3d3508@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Sep 21, 2007 at 07:00:21 -0300, Arnaldo Carvalho de Melo wrote:
> Reorganizing the resulting source code to match Linux kernel
> guidelines is something we should try to do from the start, but also
> should not get in the way of having code that works first.

Agreed. However it seems I'm still not fully aware of the process.
Quoting another thread:

On Tue, Sep 25, 2007 at 10:01:32 +0100, Gerrit Renker wrote:
> |  - Rewrite all the patches (from me and Tommi) and resubmit to
> |  Gerrit as a unique patchset, as suggested by Ian. Besides, ask
> |  Gerrit to overwrite the current ccid4 branch;

> The ideas sound good, and I think it is a good idea to factor out what
> is not needed - just unclear which patch set to use, the latest so far
> is from Thursday?

Is overwriting an existing branch common practice, or simply used here
to cover our tracks of the initial confusion?-) Obviously we needed some
sort of starting point, and thus my mutilated copy of CCID 3 got in
early and unreviewed. Anyway, I think we should fix the existing trivial
issues (such as my mistakes to refer to non-existent RFCs instead of
Internet Drafts), overwrite the branch once more, and then start working
on splitting CCID 3.

Now that my patches have already been merged, how exactly should the
patches be dealt with? Naturally the patches need to be against the
current branch, but should or should I not start a new thread for the
patches?

