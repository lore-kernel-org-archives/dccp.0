From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 31 Jul 2009 19:23:26 +0000
Subject: Re: How can i retrieve the ecn nonce information in a dccp datagram
Message-Id: <20090731192326.GA4439@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210907131839t545900dfjf7c9dfd529fbecb5@mail.gmail.com>
In-Reply-To: <cb00fa210907131839t545900dfjf7c9dfd529fbecb5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|       we made the merge between the CCID4 (with our new patches) and ECN
|    trees to allow us implement some features of TRFC-SP. The merge was a
|    success (neither compile error nor kernel panic :P). Everything is working
|    fine :)!
Thanks indeed for testing, please see below.

|    However we are in doubt about what dccp tree branch our patches should be
|    applied, because the TRFC-SP has relation with CCID4 branch but also
|    depends of ECN branch Therefore, these patches don't strictly fit with ecn
|    or ccid4 branch.
|    So, what should we do about it?
Good point - I think it is essential to reorganise the tree, to simplify
merging operations. Step one is the question below:

|    I have another doubt, how stable the ECN branch is? Are there a lot
|    improvements to be done in the next few days or weeks?
The implementation is basic but I'd say it is sufficient for now. In its present
state, it should be considered stable, in particular the CCID-3 implementation.

The implementation has been tested and has been running without any known problems
for several months. If any bugs surface, they will of course be addresses. 

Here is the list of things that will need further work:

 1) There is an experimental Kconfig option "Interpret ECN congestion-experienced
    packets as lost" (commit 81a94d9e15c76d28b18f17ffd0c2ed178da249e6) which I
    would like to take out before merging it with the main test tree. 
    This is an earlier option for experimentation only. People at Thales France
    have tested it, and the results show that the performance of "translating"
    an ECN-CE event into a standard DCCP loss event reduces efficiency and
    responsiveness.

 2) There is IPv6 support but it is very ugly. I have started to work on a better
    solution. But since this touches other networking code paths, it could take
    a while until a more solution has been approved.
    Even though it is ugly, it does work, so my suggestion for the moment is to
    keep the IPv6 ECN support as it is while sorting out a better solution. The
    patch that this refers to is called "net: Hack to enable IPv6 ECN support"
    (commit 5564ed8b54156b75540b637895a95c37ca71dc3a). I have posted a question
    about this on netdev already. Suggestions are welcome.

 3) Only a single ECN codepoint, the default ECT(0) as per RFC 3168 is supported.
    This is in agreement with other Linux transport protocols, but could in some
    later future be extended.

 4) Still on the ToDo list is a review of CCID-2. I think it still needs more 
    work, but this is a general issue and not specific to ECN.

To come back to your question from above, I would like to ask whether people
are generally OK with merging the ECN-subtree into the dccp test tree
  - without the patch from (1) above,
  - with the IPv6 ECN hack (2) as no more than a temporary solution,

I have not seen your CCID-4 patches but assume they apply on top of the dccp
test tree. I think this would make things easier:
  - no need for a separate patch
  - the current CCID-4 implementation would come with ECN enabled
  - you could merge your patches easier.

Once this is done, I would like to encourage submitting CCID-4 patches also
so that we can update the CCID-4 tree.

Gerrit
