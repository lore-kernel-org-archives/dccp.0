From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 17 Jun 2008 11:16:38 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080617111638.GA14409@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| In other words the basic question is: do we want to add new parameters to
| existing qpolicies (then we need parameter discovery) or we don't want new
| parameters (then we don't need information about parameters available at
| runtime).
|
| Having defined the alternatives it's time to decide which is better. I, of
| course, claim that mine (which is adding new parameters to existing
| qpolicies). That's simply because I think that providing both
| DCCP_SCM_TIMEOUT and DCCP_SCM_PRIORITY parameters may be useful. And I don't
| see an obvoius way of achieving that goal with "new policy for new parameter"
| approach.
I agree that providing both parameters may be useful, but don't see this
as a place of contradiction.

In the kernel I think it is best to make it type-safe, i.e. no new parameters
to already-defined policies. But I can't see how this would restrict the use.

In particular, the following is possible:

 (a) defer the dynamic runtime discovery to an application-library (wrappers
     around system calls which, according to the presented information,
     select an appropriate qpolicy and fill in its parameters);
 (b) add rules to allow runtime-switching of policies: for example,a user first
     selects "prio", but then provides a timeout parameter. Instead of returning
     "parameter not understood", the interface could simply `upgrade' the current
     policy from "prio" to "timed-prio". A matrix is below.

| I hope this lengthy text is understandable. Either way, the question is
| simple: what is your concept of adding DCCP_SCM_TIMEOUT parameter?
We find both 'atomic' and 'aggregate' (combined) policies:
 1) "prio"    standalone,
 2) "timeout" standalone,
 3) "prio"    combined with "timeout" (called something like "timed-prio").

With regard to parameters, this leads to the following matrix:

    +-------------+--------+-------------------+------------------+
    | Policy Name | Policy |         Presence of Parameters       |
    |             | ID#    | DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT |
    +-------------+--------+-------------------+------------------+
    | "simple     |   0    |        no         |       no         |
    | "prio"      |   1    |        YES        |       no         |
    | "timed-prio"|   2?   |        YES        |       YES        |
    +-------------+--------+-------------------+------------------+


| > With a manpage I mean to document
| Is there any "man dccp"?
|
Not yet. If you or someone else can find time to contribute towards a DCCP manpage,
that would be just great. The best available information so far is on the OSDL pages
for DCCP and Documentation/networking/dccp.txt.

I think there is a special maintainer for the kernel manpages, who could
be emailed with a basic manpage. But ther ere is a similar problem - if the
API changes frequently, then this requires to update the manpage accordingly.

As alternatives to documentation, there are for example providing
 *running source code,
 * web pages or
 * use cases posted to this list
 * ...
