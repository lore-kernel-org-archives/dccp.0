From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Nov 2009 06:35:00 +0000
Subject: Re: Doubt in implementations of mean loss interval at sender side
Message-Id: <20091123063500.GA4767@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B861.7040107@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B861.7040107@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > To clarify, I was asking whether it would be possible for the sender to
| > perform step (2) of RFC 5348, 6.2; to compensate for the fact that the
| > receiver does not have a reliable RTT estimate.
|
| I understand now the issue, thanks. Isn't better to just send the RTT estimate
| to the sender, as the RFC says?
|
This is confusing me: do you mean sending RTT estimates according to
 * RFC 4342 (coarse-grained window counter approximating RTT/4) or
 * RFC 5348 (using a genuine, not counter-based, timestamp)?

I personally think that the second option is more precise/robust.  With regard
to the  Todo list of issues below, I suggest for the moment to keep this as a
"known problem" -- if something related to X_recv is not functioning well, the
RTT measurement would be likely source (testing can be done by looking at the
dccp_probe plots). If it turns out that the receiver RTT measurement degrades
performance, I am willing to work on it.


| >> Accordingly to ecn nonce echo sum algorithm, if a receiver is found to be
| >> lying about loss or to be bad implemented, the sender adjusts the send rate
| >> as if loss were perceived.
| >> Can we do the same in this situation? If so, can we skip checking options
| >> between them and only check ecn nonce sum?
| > This is difficult since Ack Vectors and Loss Intervals use different
| > definitions of ECN Nonce sum (last paragraph in RFC 4342, 9.1), i.e. we have
| >  6) separate algorithms to compute Ack Vector/Loss Intervals ECN Nonce sum.
| >
| > With regard to (5) above, your suggestion gives
| >  7) validate options, on mismatch other than (5) only validate ECN nonce.
| >
| >> If some option is wrong it show more loss (or any worse situation for the
| >> receiver) or conceals loss. In the first case, I don't believe we need to care,
| >> and in the second, the ecn nonce sum can reveal the bad acting of the receiver.
| > Yes you are right, we need not worry if a receiver reports a higher loss rate
| > than the verification done by the sender (which recomputes the data that the
| > receiver already has computed) calculates.
| >
| > But for the second case, there is no guarantee to catch a misbehaving
| > receiver, only a 50% chance at the end of many computations.
|
| Isn't it 50% chance at each ecn verified? So, at the end we'll end up with
| 100%?
|
I wished it were as simple as that, but the probabilities can not simply be added.
They are combined according to a statistical law, so that in the end the answer
to the question "did the receiver lie" is neither "yes" nor "no", but rather 
something like "0.187524".

In my view, ECN Nonce is also something that can be left for the second stage,
the justification being that the ECN verification serves as protection for
something which is (supposed) to work well on its own. The 'bare' protocol
behaviour can be tested with a known receiver, calibrated to the spec. behaviour.


| > To conclude, I still think that the simpler, receiver-based implementation
| > gives a better start. A 'perfect' receiver implementation is also a good
| > reference point to start protocol evaluation: if the performance is bad
| > despite getting things right at the receiver, then other parts of the
| > protocol need investigation/improvement.
|
| I agree. It's a risk to work on the sender at the moment, implementing these
| features, algorithms and ending with a CCID that doesn't match the expected
| performance.
|
| Can you list the pending tasks in both code and tests to be done?
|
This is a very good point, thank you. Below is my sketchy list of points so
far. There is certainly room for discussion and I am open to suggestions: it
would be great to update the 'old' DCCP-ToDo on
http://www.linuxfoundation.org/collaborate/workgroups/networking/todo#DCCP
with the outcome.


I) General tasks to do (affect CCID-4 indirectly)
-------------------------------------------------

 1) Audit the TFRC code with regard to RFC 5348
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    There are still many references to 'rfc3448bis' in the (test-tree) code, which
    was the draft series that preceded RFC 5348. The code is lagging behind the RFC
    still, since during the draft series there were many changes, which now have
    finalised.
    This step is complicated, since it touches the entire TFRC/CCID-3 subsystem
    and will need careful testing to not introduce new bugs or deteriorate the
    performance (meaning that the current state is good to some extent already).
    Have been plannig to do this for a long while, will probably not be before
    December.

 2) Revision of the packet-sending algorithm
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Luca de Cicco is working on this, there is a new algorithm for scheduling
    packets in order to achieve the desired X_Bps sending rate. It will be very
    interesting to see whether/how this improves the sender side (i.e. for now
    it is still experimental).		    


II) Tests
---------

 3) Regression / test automation
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    It would be good to have some kind of regression test to be run for defining
    "acceptable performance", so that we have a base case to look at when adding
    more features or changes. Can you check to what extent the CCID-3 tests on
    http://www.linuxfoundation.org/collaborate/workgroups/networking/dccp_testing#Regression_testing
    help with CCID-4? My level of CCID-4 testing so far has been along these lines,
    but it is a bit restricted (the throughput always stops at 1.15 Mbps). 

    A second helpful kind of test is visualisation via dccp_probe, checking
    each of the input parameters and their influence on the protocol machinery.

 4) Internet experiments
 ~~~~~~~~~~~~~~~~~~~~~~~
    This may be the biggest area lacking work but is really essential. Many 
    simulations seem to say that DCCP is wonderful. But the practice is also
    full of wonders, so that it may be a different kind of wonderful.

    Main issues to tackle are
     * NAT traversal (there exists already work for a NAT-traversal handshake,
       both in form of an IETF spec and in code) and/or
     * UDP tunnelling (yes it is ugly, but has worked initially for IPv6 also).


II) CCID-4 tasks
----------------
These are only the issues summarized from this mailing thread. Likely you will
have comments or other/additional ideas - this is not set in stone.

 5) Finish a "pure" receiver-based implementation, to test the CCID-4 congestion
    control on its own. As far as I can see this involves modifying the loss
    intervals computation done at the receiver, where you already have done a lot
    of work.

 6) Add more features (sender-side support, verification of incoming options at
    at the sender, ECN verification ...) as needed, using the regression tests
    defined in (2) to check the performance. When doing this we can use the
    past mailing thread as input, since several good points already resulted 
    from this. In particular, it is now clear that when sending loss interval
    options from the receiver to the sender, we need not send 28 loss intervals
    (RFC 4342, 8.6), nor 84 loss intervals accompanied by Dropped Packet options
    (RFC 5622, 8.7), but rather the 9 used by TFRC (RFC 5348, 5.4) as basis.
