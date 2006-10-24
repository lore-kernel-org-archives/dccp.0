From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 24 Oct 2006 07:53:53 +0000
Subject: Re: 2.6.19-rcX vs 2.6.20
Message-Id: <39e6f6c70610240053wf0e4483n87e1e14ceed8618c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200610240848.47708@strip-the-willow>
In-Reply-To: <200610240848.47708@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/24/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> It seems that I am not the only one having headaches about which patches
> are applied and which not. I spent a major part yesterday trying to get
> the set of patches consistent with regard to Dave's/Arnaldo's latest tree.
>
> What I have been doing over time is collecting all patches that were posted on this
> list and have not made it upstream into a consistent, stacked set of patches.
>
> With my own work this adds up to currently 17 patches, including:
>         * 3 patches from Andrea which have also not been merged
>         * 1 patch (typo) by Ian which has not been merged
>         * patches from me with annotations that Arnaldo made incorporated
>         * a few bug fixes (see also earlier posting)
>         * general updates (such as the one Ian pointed out, but also the
>           second part of the oops patch to reduce the number of forward decls)
>
> Every day, after pulling, I have to reconstruct the whole stacked batch of patches
> by applying them one after the other again. Even the script which does this is tedious.
> Now I see the headaches it costs Arnaldo as well and hence:
>
>   => Is there any way of using a separate DCCP repository for the mere purpose of
>       keeping accepted and discussed patches in a consistent state?
>
> It is little point if everyone keeps a separate stack of patches. On the other hand, it
> is frustrating work having to chase after old and partially applied patches, battle with
> rebased trees, merged close windows etc.
>
> With regard to 2.6.19-rX vs 2.6.20 I think that it is better not to submit more patches
> not (only) because David said so, but with regard to `postponing headaches': all non-2.6.19-rX
> patches have later again to be rebased/changed. Yesterday, this killed two of my repositories
> and I had to change each manually from scratch again.
>
>
> Arnaldo, what do you think is best ? I think it would be ideal if there was a consistent
> tree, that would save a lot of work.
>
> What I could contribute to make this easier is to keep track of changes and merging (i.e.
> the grunt work) - I am pulling the latest netdev tree daily anyway. Would this help? I am
> not insinuating bypassing the revision process, but I am getting tired of rebasing.
>
> Well I hope it won't stay like this forever ...
>
>
>
> PS: Ian, for a laugh I attach a script which I have been using a lot, it basically
> answers your question `is this upstream or not' - in colour :)

Well, I'm not being a diligent maintainer, have to review many patches
yet, I guess I should just create a net-2.6.20 git tree to fix this
situation, but I guess you guys could also maintain git trees
somewhere, so that I could pull from you, what do you think?

- Arnaldo
