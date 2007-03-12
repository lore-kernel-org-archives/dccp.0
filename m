From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 12 Mar 2007 17:14:12 +0000
Subject: Re: [ANNOUNCE]: Patch Preview
Message-Id: <39e6f6c70703121014g31a66170h8992fc3ad1ae612d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703121557.12709@strip-the-willow>
In-Reply-To: <200703121557.12709@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I have put quite a lot of work into
>   * bringing CCID 3 up to spec
>   * implement loss detection according to RFC 3448/4342
>   * add loss intervals handling according to rfc3448bis
>   * many cool new features
>   * ample documentation, applications, and test modules for most features
>
> However, since patches are small for review-ability, this amounts to a total of 75 patches,
> including the patch backlog; please see suggestion (2).
>
> 1. PREVIEW: Since mostly the following files are modified:
>       net/dccp/ccids/lib/ccid3.*
>       net/dccp/ccids/lib/loss_interval.*
>       net/dccp/ccids/lib/packet_history.*
>    I have posted combined patches onto
>
>    http://www.erg.abdn.ac.uk/users/gerrit/dccp/patches_working-set/
>
>    These apply in-order (see series file) onto today's tree. They have been extensively tested,
>    can offer a test module for most essential features.
>
>
> 2. SUGGESTION: Since the patch backlog is really quite old now (over 2 months), I would like
>    to suggest to re-submit it as one, combined patch, in the format of
>    http://www.erg.abdn.ac.uk/users/gerrit/dccp/patches_working-set/01_The_Patch_Backlog.diff
>    (maybe a bit more verbose)
>    => But this depends on whether people are ok with this (see (3))

No, what I think is the best to do is to consider your patch backlog
as a separate git tree that now will be pulled, preserving the
changesets history.

- Arnaldo
