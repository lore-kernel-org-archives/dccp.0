From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 04 Dec 2007 11:59:39 +0000
Subject: Re: [PATCH 7/7] [TFRC] New rx history code
Message-Id: <20071204115939.GA18084@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-8-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-8-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Dec 04, 2007 at 06:55:17AM +0000, Gerrit Renker escreveu:
> NAK. You have changed the control flow of the algorithm and the underlying
> data structure. Originally it had been an array of pointers, and this had
> been a design decision right from the first submissions in March. From I
> of http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/loss_detection/loss_detection_algorithm_notes.txt
>  
>  "1. 'ring' is an array of pointers rather than a contiguous area in
>      memory. The reason is that, when having to swap adjacent entries
>      to sort the history, it is easier to swap pointers than to copy
>      (heavy-weight) history-entry data structs."
> 
> But in your algorithm it becomes a normal linear array.
> 
> As a consequence all subsequent code needs to be rewritten to use
> copying instead of swapping pointers. And there is a lot of that, since
> the loss detection code makes heavy use of swapping entries in order to
> cope with reordered and/or delayed packets.

So lets not do that, the decision was made based on the RX history patch
alone, where, as pointed out, no swapping occurs.
 
> This is not what I would call "entirely equivalent" as you claim. Your
> algorithm is fundamentally different, the control flow is not the same,
> nor are the underlying data structures.

Its is equivalent up to what is in the tree, thank you for point out
that in subsequent patches it will be used.

Had this design decision been made explicit in the changeset comment
that introduces the data structure I wouldn't have tried to reduce the
number of allocations.

And you even said that it was a good decision when first reacting to
this change, which I saw as positive feedback for the RFC I sent.

> | Credit here goes to Gerrit Renker, that provided the initial implementation for
> | this new codebase.
> | 
> | I modified it just to try to make it closer to the existing API, hide details from
> | the CCIDs and fix a couple bugs found in the initial implementation.
> What is "a couple bugs"? So far you have pointed out only one problem and that was
> agreed, it can be fixed. But it remains a side issue, it is not a failure of the

I pointed two problems one ended up being just the fact that tfrc_ewma
checks if the average is zero for every calculation.

> algorithm per se. What is worse here is that you take this single occurrence as a
> kind of carte blanche to mess around with the code as you please. Where please are
> the other bugs you are referring to?

I mentioned in the previous messages, one was a problem, the other you
clarified that was not a problem, but could be optimized.
 
> I am not buying into this and am not convinced that you are understanding
> what you are doing. It is the third time that you take patches which
> have been submitted on dccp@vger for over half a year, for which you
> have offered no more than a sentence of feedback, release them under
> your name, and introduce fundamental changes which alter the behaviour.

I commited it under my name because I changed it, while giving you
credit.
 
> The first instance was the set of ktime patches which I had developed
> for the test tree and which you extended to DCCP. In this case it were
> in fact three bugs that you added in migrating my patches. I know this
> because it messed up the way CCID3 behaved and since I spent several
> hours chasing these. And, in contrast to the above, it is not a mere
> claim: that is recorded in the netdev mail archives.

I'm sorry you feel so strongly when back and forth you express gratitude
and then you show contempt for my behaviour.

> The second instance was when you released the TX history patches under
> your name. Pro forma there was an RFC patch at 3pm, de facto it was
> checked in a few hours later: input not welcome.

Have you found any problems in it? Look again at the changeset to see if
I "stole" your code as you seem to imply:

commit 02271b56fd4028820e68e85e9d468628f42fb6ab
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Wed Nov 28 11:15:40 2007 -0200

    [TFRC]: Migrate TX history to singly-linked lis

    This patch was based on another made by Gerrit Renker, his changelog was:

        ------------------------------------------------------
    The patch set migrates TFRC TX history to a singly-linked list.

    The details are:
     * use of a consistent naming scheme (all TFRC functions now begin
     * with `tfrc_');
     * allocation and cleanup are taken care of internally;
     * provision of a lookup function, which is used by the CCID TX
     * infrastructure
       to determine the time a packet was sent (in turn used for RTT sampling);
     * integration of the new interface with the present use in CCID3.
        ------------------------------------------------------

    Simplifications I did:

    . removing the tfrc_tx_hist_head that had a pointer to the list head and
      another for the slabcache.
    . No need for creating a slabcache for each CCID that wants to use the TFRC
      tx history routines, create a single slabcache when the dccp_tfrc_lib module
      init routine is called.

    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Is this enough credit? I can make the process slower and simply post
these patches and wait till you review it and incorporate the changes.
 
> The third instance is now where you change in essence the floor
> underneath this work. Since you are using a different basis, the
> algorithm is (in addition to the changes in control flow) necessarily
> different. 

You are picking something I did on a RFC patch and exaggerating on your
reaction.

> I have provided documentation, written test modules, and am able to prove
> that the algorithm as submitted works reasonably correct. In addition, the
> behaviour has been verified using regression tests.
> 
> I am not prepared to take your claims and expressions of "deepest
> respect" at face value since your actions - not your words - show that
> you are, in fact, not dealing respectfully with work which has taken
> months to complete and verify.
> 
> During 9 months on dccp@vger you did not provide so much as a paragraph
> of feedback. Instead you mopped up code from the test tree, modified it
> according to your own whims and now, in the circle of your
> invitation-only buddies, start to talk about having discussions and 
> iterations. The only iteration I can see is in fixing up the things you
> introduced, so it is not you who has to pay the price.
> 
> Sorry, unless you can offer a more mature model of collaboration,
> consider me out of this and the patches summarily withdrawn. I am not
> prepared to throw away several months of work just because you feel
> inspired to do as you please with the work of others. 

Again you want to have your patches accepted as-is. Pointed to one case
where I gave you credit while improving on your work (TX history) and
another where the changes were up for review. I don't consider this a
warm welcome for me to finally dedicate time to this effort. Would you
prefer to continue working without help? I think we should encourage
more people to work on DCCP, you seem to think that changes to your work
are not acceptable.

Perhaps others can comment on what is happening and help us find, as you
say, to find a more mature model of collaboration.

- Arnaldo
