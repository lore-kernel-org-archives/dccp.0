From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 14 Jul 2008 12:58:40 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080714125840.GA12320@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| >
| > I can think of at least two ways of tackling this -- maybe there are more:
| >
| >   (a) Separate policies for "prio" and "prio with timeout"
| >       ---------------------------------------------------
| >       Would be resolved when trying to set "prio with timeout" policy - the
| >       kernel would either accept (and understand) it or return an error.
| >
| So we would have "simple", "prio" and "prio with timeout" policies. The 
| questions are:
| 1. Should we have "timeout" policy as well?
| 2. Should we have "prio without priority"* policy as well?
| 
| * On this example we clearly see that prio is not the best name possible. 
| Maybe something like "realtime policy" would be better? Because the key 
| difference to "simple" policy is the fact that send never waits (ie. the 
| queue seems to be never full). Maybe there exists an even better name 
| than "realtime". What do you think of changing the name?
| 
I am much in support of (1) since this will be the default for many
applications which are based on a best-before time value (RTP-based
applications, video streaming for instance).

With regard to defining "salami baguette without salami", it would be best to
write short, one-sentence descriptions of the behaviour of each policy. This 
makes it easier to later add documentation (manpage) and also to find an
appropriate name. I had to look up "prio":

DCCP_SOCKOPT_QPOLICY_TXQLEN sets [...] 
the "prio" policy enforces a fixed queue length by dropping the
lowest-priority packet first.

=> So call it something like "drop_lowest_prio_first"?


| >       If this is the case then we need to step back and sort 
| >       out the base policies plus set of optional parameters, and find a
| >       way of dealing with each combination. At first sight, this seems
| >       more difficult and complicated than (a).
| >
| For me it's not. Note that for each main policy you only have to think about 
| two things:
| 1. How should it behave if all parameters are supplied.
| 2. If not all parameters are supplied what should be their default values. For 
| priority it could be 0, for timeout it could be infinity. If you cannot think 
| of a sensible default value for a parameter it is a sign that new policy 
| should be created.
| 
| In effect you don't have to think about each combination of parameters 
| separately.
| 
I am not sure I understand this. When it is used in a computer, the
parameters and the algorithm need to be well-defined.


| > Not directly related to above questions, but rather as inspiration I
| > attach the sketch which I did for the definition of qpolicies. The idea
| > is to use a separate enum for each combination of parameters. The first
| > entry is initialised using the parameter bitmask, subsequent entries
| > have subsequent numbers.
| > 
| 1. I would summarise difference in our ideas as follows:
| My approach: we have an algorithm (policy) and let's think what can affect the 
| behaviour of this algorithm => algorithm is first, set of parameters is 
| second.
| Your approach: we have a set of parameters and let's think what algorithm 
| (policy) can be used to manage them => set of parameters is first, algorithm 
| is second.
| 
| 2. By choosing policy DCCPQ_POLICY_TIMED_REVERSE_PRIO you basically give the 
| kernel two pieces of information:
|   a) what set of parameters will be used (QPOLICY_INITIALISER(QP_PARAM_PRIO|
| QP_PARAM_TIMEO)),
|   b) how packets will be managed in a queue 
| (DCCPQ_POLICY_TIMED_REVERSE_PRIO-QPOLICY_INITIALISER(QP_PARAM_PRIO|
| QP_PARAM_TIMEO)).
| 
| Do we agree in these points?
| -- 
Yes we do - we are just using different names for the same things.
