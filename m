From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 05 Dec 2007 12:08:01 +0000
Subject: Re: [PATCH 7/7] [TFRC] New rx history code
Message-Id: <20071205120801.GN29972@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-8-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-8-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Dec 05, 2007 at 09:35:30AM +0000, Gerrit Renker escreveu:
> Quoting Arnaldo:
> | Em Tue, Dec 04, 2007 at 06:55:17AM +0000, Gerrit Renker escreveu:
> | > NAK. You have changed the control flow of the algorithm and the underlying
> | > data structure. Originally it had been an array of pointers, and this had
> | > been a design decision right from the first submissions in March. From I
> | > of http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/loss_detection/loss_detection_algorithm_notes.txt
> | >  
> | >  "1. 'ring' is an array of pointers rather than a contiguous area in
> | >      memory. The reason is that, when having to swap adjacent entries
> | >      to sort the history, it is easier to swap pointers than to copy
> | >      (heavy-weight) history-entry data structs."
> | > 
> | > But in your algorithm it becomes a normal linear array.
> | > 
> | > As a consequence all subsequent code needs to be rewritten to use
> | > copying instead of swapping pointers. And there is a lot of that, since
> | > the loss detection code makes heavy use of swapping entries in order to
> | > cope with reordered and/or delayed packets.
> | 
> | So lets not do that, the decision was made based on the RX history patch
> | alone, where, as pointed out, no swapping occurs.
> |  
> | > This is not what I would call "entirely equivalent" as you claim. Your
> | > algorithm is fundamentally different, the control flow is not the same,
> | > nor are the underlying data structures.
> | 
> | Its is equivalent up to what is in the tree, thank you for point out
> | that in subsequent patches it will be used.
> | 
> | Had this design decision been made explicit in the changeset comment
> | that introduces the data structure I wouldn't have tried to reduce the
> | number of allocations.
> | 
> | And you even said that it was a good decision when first reacting to
> | this change, which I saw as positive feedback for the RFC I sent.
> | 
> That was my fault. Your solution "looked" much better to me but even I had forgotten
> that the algorithm is based on an array of pointers. When I finally sat down 

And you wrote that code, I acted on looking the code together with
reading the changeset comment, to me it also looked much better to do
that, but as there were many changes, I sent an [RFC] message. It served
its purpose, as you after two iterations realised it was in fact not a
good idea as later an array of pointers is required. I should have taken
that swap routine as the definitive hint that indeed it was needed.

> and looked through the patch set I found the original notes from March and
> saw that using a linear array instead of an array of pointers will require quite
> a few changes and means changing the algorithm. I then thought through whether there
> could be any advantage in using a linear array as in this patch, but could find none.
> In the end this went back to the same questions and issues that were tackled between
> February and March this year. I wish we could have had this dicussion then; it would
> have made this email unnecessary.

That is why it is important that the changeset comment collects these
scattered notes and discussions. Think about in some years from now we
will be left with a situation where we would have to look at many places
to understando some aspects of what is in the code. While this happens
and we have google for that I think that since you keep such detailed
notes it is not a problem to get them in the changesets.
 
> I thank you for your replay and I am sorry if you took offense at my perhaps a little strong
> reaction, here is the essence what I tried to convey but what maybe did not succeed in conveying:
> 
>  * I am absolutely ok with you making changes to variable names, namespaces, file organisation,
>    overall arrangement etc (as per previous email). You have experience and this will often be a 
>    benefit. For instance, you combined tfrc_entry_from_skb() with tfrc_rx_hist_update() to give
>    a new function, tfrc_rx_hist_add_packet(). This is ok since entry_from_skb() is not otherwise
>    used (and I only found this out when reading your patch). (On the other hand, since this is a
>    4-element ring buffer, it is no real adding, the same entry will frequently be overwritten,
>    this is why it was initially called hist_update().)

From the RX history API user perspective (CCID3 right now, others may
come) it is adding a packet to the history. In the past it went to a
list, now we have a ring and don't keep more than TFRC_NDUPACK + 1
entries, but this is an internal detail that users don't need to know.
 
>  * I am also not so much concerned about credit. As long as the (changed) end result is as
>    least as good as or hopefully better than the submitted input, the author name is a side
>    issue; so I do think that your approach is sound and fair. The only place where credits
>    are needed is for the SatSix project (www.ist-satsix.org) which funded this work. This is
>    why some of the copyrights now included "University of Aberdeen".  What in any case I'd like
>    to add is at least the Signed-off-by: if it turns out to be a mess I want to contribute my
>    part of responsibility.

And that, along with credit to you is being provided on the few patches
I change.
 
>  * But where I need to interact is when changes are made to the algorithm, even if these may 
>    seem small. The underlying reasons that lead to the code may not be immediately clear,
>    but since this is a solution for a specific problem, there are also specific reasons; which
>    is why for algorithm changes (and underlying data structure) I'd ask you to discuss this first
>    before committing the patch. 

I did this for the RX handling, where changes were made. Did that for
the TX but ended up commiting before comments from you, but I think its
fair to say that the changes for the TX history were more organizational
than in the essence of the algorithm.
 
>  * In part you are already doing this (message subject); it may be necessary to adapt the way
>    of discussion/presentation. The subject is complex (spent a week with the flow chart only)
>    and it is a lot - initially this had been 40 small patches.	
>    
> | > | I modified it just to try to make it closer to the existing API, hide details from
> | > | the CCIDs and fix a couple bugs found in the initial implementation.
> | > What is "a couple bugs"? So far you have pointed out only one problem and that was
> | > agreed, it can be fixed. But it remains a side issue, it is not a failure of the
> | 
> | I pointed two problems one ended up being just the fact that tfrc_ewma
> | checks if the average is zero for every calculation.
> | 
> With regard to the tfrc_ewma we need to consider the discussion as I think we are having a
> misunderstanding. It is necessary to 
>  (a) deal with the case that a peer may be sending zero-sized packets:
>      - one solution is to simply omit the check "if (len > 0)" and declare 0-sized data
>      - I think you have a point in that the len check is indeed redundant when we are
>        already checking that this is a data packet
>        packets as pathological (which is probably what they are);
>      - a BUG_ON would be not such a good solution since 0-sized packets are legal;
>      - my suggestion is to remove the "len > 0" test - then tfrc_ewma() can also be
>        used directly, without the surrounding inline function wrapper.
> 
>  (b) reconsider the control flow: in your patch set you introduced a different control flow
>      in the rx_packet_recv() function. I tried to figure out why this was introduced, there
>      are two problems, one not immediately obvious at this moment:
>      - it does not consider where and how loss detection is done (which is part of a later
>        patch). This is a key point why the flow may seem strange: loss detection must be
>        done on both non-data and data packets; there are several cases depending on whether
>        loss previously occurred; the accounting must also be done in parallel for data packets
>        (for instance s and bytes_recvd) and non-data packets (highest-received seqno is always
>      - it is not equivalent with the initial one, when comparing this to the flowchart:
>        http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/reception-main-flowchart.png

I will revert to your original flow.
 
> | > I have provided documentation, written test modules, and am able to prove
> | > that the algorithm as submitted works reasonably correct. In addition, the
> | > behaviour has been verified using regression tests.
> | > 
> | > I am not prepared to take your claims and expressions of "deepest
> | > respect" at face value since your actions - not your words - show that
> | > you are, in fact, not dealing respectfully with work which has taken
> | > months to complete and verify.
> | > 
> | > During 9 months on dccp@vger you did not provide so much as a paragraph
> | > of feedback. Instead you mopped up code from the test tree, modified it
> | > according to your own whims and now, in the circle of your
> | > invitation-only buddies, start to talk about having discussions and 
> | > iterations. The only iteration I can see is in fixing up the things you
> | > introduced, so it is not you who has to pay the price.
> | > 
> | > Sorry, unless you can offer a more mature model of collaboration,
> | > consider me out of this and the patches summarily withdrawn. I am not
> | > prepared to throw away several months of work just because you feel
> | > inspired to do as you please with the work of others. 
> | 
> | Again you want to have your patches accepted as-is. Pointed to one case
> | where I gave you credit while improving on your work (TX history) and
> | another where the changes were up for review. I don't consider this a
> | warm welcome for me to finally dedicate time to this effort. Would you
> | prefer to continue working without help? I think we should encourage
> | more people to work on DCCP, you seem to think that changes to your work
> | are not acceptable.
> | 
> Yes and no. The internal algorithm I would rather have accepted as-is, unless
> there are good reasons to change it. But this by no means means I want this 
> waved through like a diplomat's car at the border: there are reasons why
> it is as it is, and I am happy to discuss these reasons; and if someone
> can point out a better solution, will accept that. It is just that this
> is a solution to a specific problem which so far has proven to work, and
> I therefore think that we can spent the time more efficiently by not
> fixing things that have already been fixed once: there are many more
> problems in DCCP (just recently you mentioned robustness of memory usage,
> then there is the ongoing discussion of how to integrate CCID4 as well);
> I think we could divide up work time with more benefit.

OK, I think I exaggerated on the changes and that you exaggerated on the
reaction, lets try to tone down both behaviours and we'll move on.
 
> | Perhaps others can comment on what is happening and help us find, as you
> | say, to find a more mature model of collaboration.
> | 
> No need to be cynical, you have replied gracefully and with substance.
> For that I thank you. The topic is complicated, adapting how it is
> treated may improve the discussion - for instance, if it helps, we could
> switch back to smaller patch format as original, which you have already
> been introducing.

No intention, I was fearing your reaction would escalate and asking for
other people that are more experienced in maintainership, telling about
my and your mistakes in interacting could help. But I think we're going
back on track by ourselves, thank you.

- Arnaldo
