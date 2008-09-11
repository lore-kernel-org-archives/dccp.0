From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Sep 2008 05:45:26 +0000
Subject: What to do with DCCP (was:  net-next-2.6 [pull-request] [PATCH
Message-Id: <20080911054526.GB3707@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a reply to the earlier email, the question of what to
do with DCCP is at the end. Basically I would be ok if someone
else familiar with DCCP wanted to take over. 
What then still may cause problems is that DCCP is still a
work-in-progress, please see at end of message.

| You can't seem to get the whole review process right, yet it's the
| most important aspect of getting changes into the tree.  It's 1,000
| times more important that implementing the code in the first place.
| 
This is simply not true. For this request the review process began
a year ago, the patches have been resubmitted several times and have 
been available in a test tree which gets updated almost daily. We tested
this code ourselves extensively in the EU Satsix project. Also, the
publicly available gstreamer DCCP plugin has been using this API.

| For starters, you don't dump 30 or 40 patches on people's laps for
| review.  You give them 5, maybe 10, at a time.  And you submit them
| when you write them, so that you don't have to rewrite everything
| after the ones that need fixups.
| 
This is only possible when using huge patches and then people will complain
that the patches contain too many different things. You yourself said
something like this earlier.

I am happy to change the format, but it seems there is no way to make it
right to everyone - either I get accused of putting too much into one patch,
or I get accused of sending too many patches of a finer granularity.


| And once you've submitted a large chunk of changes like you did this
| time, you've worn out your reviewer pool, and they'll need a long
| recovery period before they can devote time to looking at this stuff
| again.
| 
Ack.


| > | Don't warn about crap like this, instead convert the code over to hrtimers.
| > | 
| > | This kernel being built, even with HZ0, can do nanosecond timers on
| > | my systems, but that's only if you would make proper use of them.
| > | 
| > The present sk_timer implementation uses the algorithm from RFC 3448. I
| > did not want to blindly port it to hrtimer since so far the following
| > difficulties were in the way:
| > 
| >  * when using the algorithm from RFC 3448, 4.6 directly with hrtimers,
| >    a large burst of activity will result, especially on fast links;
| > 
| >  * I have doubts whether it will help: each time the precision is improved,
| >    more frantic high-frequency noise results in CCID-3:
| 
| To me this is just pure bullshit, I'm sorry to say.
| 
| A warning gets added that barks at the person compiling this stuff
| saying: "YOUR TIMER ISN'T ACCURATE ENOUGH" and now you're telling me
| your concerned that hrtimers might give too much accuracy.
| 
| Which is it?
| 
| Lower limit the hrtimer interval, or make it as course as you damn
| well need, anything but this pile of excuses.
| 
| HZ0 is extremely common, and there is no reason to bark at people
| about something they can do absolutely nothing about.  Who in the
| world is supposed to act upon that warning?
| 
The warning is enabled only if DCCP is configured into the kernel or as
module. It is interesting to see someone else suggesting hrtimers here.
When hrtimers became available I had suggested this on dccp@vger, but
there was a lot of opposition/disagreement about it.

It is easy to make strong words. If you are really convinced that it is
so easy then without making CCID-3 oscillate, please let's see a patch.
I have laboured for 2 years on making CCID-3 less unpredictable/frantic
and doubt it is so easy.


| Yet now everyone building the linux -next tree will see it if their HZ
| is choosen to be low enough and we'll thus get piles of "what's this?"
| queries on all the lists.
| 
If it becomes a bother please feel free to forward the stuff to this inbox.


| Look...
| 
| This whole process isn't going smoothly.  You are time limited, and
| the place you are short changing, time wise, appears to be the whole
| submission and review process.  Yet this should be your highest
| priority, far and above implementing even one single line of code.
| 
You have convinced me that this `time-limited' point really is invalid.

It leads to annoyances and the wrong choices. I will stick around and
find some time until this part has been resolved. And if people want to
take longer for their review, fine. It is just that this review phase
has taken almost a year now.

It is also not possible to make the review process much easier, since
DCCP is a largely untested research protocol. Many of its features and
algorithms have only been tested in simulation, and there are lots
of little algorithms and later-added-features, all interacting with
one another. This is labour-intensive for writers and reviewers of
patches, but convenient for writers of specs, who get bugs in their
documents fixed for them at no expense.

To free your energy for more important work, one might consider doing
all of the DCCP stuff in an experimental tree and merge it back later,
once all the long-discussion issues have been resolved.
