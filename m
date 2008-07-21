From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 21 Jul 2008 16:24:38 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080721162438.GA5055@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | So we would have "simple", "prio" and "prio with timeout" policies. The
| > | questions are:
| > | 1. Should we have "timeout" policy as well?
| > | 2. Should we have "prio without priority"* policy as well?
| > |
| > | * On this example we clearly see that prio is not the best name possible.
| > | Maybe something like "realtime policy" would be better? Because the key
| > | difference to "simple" policy is the fact that send never waits (ie. the
| > | queue seems to be never full). Maybe there exists an even better name
| > | than "realtime". What do you think of changing the name?
| >
| > I am much in support of (1) since this will be the default for many
| > applications which are based on a best-before time value (RTP-based
| > applications, video streaming for instance).
| >
| The question is not whether such a behaviour should be available to 
| applications. We both agree that it should. The question is: should it be a 
| separate policy? This is question about name, not about functionality.
| 
Yes - I think there should be a separate policy name for each
algorithm that uses a given set of parameters. The discussion about
multiple parameters is further below in the email; for single parameters
there is no other choice.


| > With regard to defining "salami baguette without salami", it would be best
| > to write short, one-sentence descriptions of the behaviour of each policy.
| > This makes it easier to later add documentation (manpage) and also to find
| > an appropriate name. I had to look up "prio":
| >
| > DCCP_SOCKOPT_QPOLICY_TXQLEN sets [...]
| > the "prio" policy enforces a fixed queue length by dropping the
| > lowest-priority packet first.
| >
| > => So call it something like "drop_lowest_prio_first"?
| >
| But then we still have "prio" in the name. So we will 
| have "drop_lowest_prio_first" without "priority". Not at all better.
| Maybe just "drop", "drop_worst" (which I don't like since it has two 
| words), "realtime" or "rt"?
| 
Hm - why do you not like the `prio'? After all, the way the packet is
treated is in a priority manner and the cmsg level for passing the 
associated parameter is DCCP_SCM_PRIORITY.

The algorithm is comparable to postal delivery which has only three
priorities (Express, Standard, and Economy). The obvious difference
is that postal delivery is reliable and takes longer (i.e. they use
unbounded queues), whereas the algorithm drops the packet with the
lowest priority value first.

The problem that I see with "realtime" is that it is like "multimedia",
which fits almost anything a vendor likes.

Ideally the name should briefly summarise the algorithm, it is not
so important which particular name - how about "drop_lowest_first"?



| > | >       If this is the case then we need to step back and sort
| > | >       out the base policies plus set of optional parameters, and find a
| > | >       way of dealing with each combination. At first sight, this seems
| > | >       more difficult and complicated than (a).
| > |
| > | For me it's not. Note that for each main policy you only have to think
| > | about two things:
| > | 1. How should it behave if all parameters are supplied.
| > | 2. If not all parameters are supplied what should be their default
| > | values. For priority it could be 0, for timeout it could be infinity. If
| > | you cannot think of a sensible default value for a parameter it is a sign
| > | that new policy should be created.
| > |
| > | In effect you don't have to think about each combination of parameters
| > | separately.
| >
| > I am not sure I understand this. When it is used in a computer, the
| > parameters and the algorithm need to be well-defined.
| >
| But we only need to define only one, maximum set of parameters and not all 
| permutations of these parameters. This simplifies things. At the very least 
| it reduces number of needed enum values.
| 
| When you convert a string value to integer it is pretty obvious that this 
| string usually contains base 10 number. But you can still define other radix 
| by specifying additional parameter. By using default parameter you don't have 
| to implement atoi2(), atoi8(), atoi10(), atoi16(), atoi17(), ... functions. 
| Implementing just one, most complex case is enough.
| 
Fully agree with the reasoning and this is a good idea - we use strtol() which
knows three parameters to express atoi() which only knows one parameter.

| Here we have the same situation: just one policy with a given behaviour is 
| enough ("realtime"). If an application wants to provide priority - fine, add 
| timeout - fine, add fooparam - fine, but it doesn't affect the basic 
| algorithm.
| 
I see three sets of parameters:
 1) The parameters that the algorithm knows about and which are used to
    describe the algorithm. This set is divided into two subsets
    (a) "interesting"   (which are always supplied) and
    (b) "uninteresting" (which may be absent) parameters --
    maybe in the way optional arguments are defined in C++?
 2) The parameters the algorithm does not know about -- defined as the set of
    all parameters for which dccp_qpolicy_param_ok() returns `false'.

I think what separates this from an implementation is just a bit of clerical
work, on deciding which case is the most general one and how to treat
absent parameters --- that perhaps use some default value.


| BTW, I'm wondering whether it would be viable to move all this qpolicy stuff 
| to userspace library. Of course it is not possible with current kernel, but 
| the longer we continue this discussion the more I am convinced that most of 
| my code should be outside kernel... There are two practical considerations, 
| though. First, it may be performance (I made no tests so I have no idea how 
| big the impact might be). Second, I need to have working code for my master's 
| thesis so I will not make any abrupt changes to my concept before October.
| -- 
I also thought in some instances that parts could be located in userspace.

With regard to the first consideration, what about using low-level primitives
in kernel space, from which then more complex operators/operations can be
built in user-space? Some testing/designing may be necessary, but I think
it would be great if there were a set of building blocks. As an aside, the
guy who implemented late data choice for TCP also used a user-space library.

The second consideration is no problem at all - it would be great to
have some work on this. As per earlier discussion, this is really a new
kind of API, a novel interface. Any work thus helps the progress.

Gerrit
